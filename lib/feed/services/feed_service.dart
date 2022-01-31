import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:either_option/either_option.dart';
import 'package:tuple/tuple.dart';
import 'package:ulid/ulid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/vm/article_comments_vm.dart';
import '../models/vm/comment_vm.dart';
import '../enums/article_filter.dart';
import '../models/vm/feed_articles_vm.dart';
import '../../account/services/account_service.dart';
import '../../general/errors/authentication_token_expired_error.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../../general/utils/policy.dart';
import '../enums/article_type.dart';
import '../models/vm/video_data_vm.dart';
import '../../general/interfaces/iimage_service.dart';
import '../../general/services/notification_service.dart';
import '../interfaces/ifeed_api_service.dart';
import '../models/vm/article_vm.dart';
import '../../general/persistence/storage.dart';
import '../../general/errors/error.dart';

class FeedService {
  final Storage _storage;
  final NotificationService _notificationService;
  final IFeedApiService _feedApiService;
  final AccountService _accountService;
  final IImageService _imageService;

  Policy _policy;

  String _title;
  String _previewImageUrl;
  String _summary;
  List<dynamic> _content;

  FeedService(
    this._storage,
    this._notificationService,
    this._feedApiService,
    this._accountService,
    this._imageService,
  ) {
    _policy = PolicyBuilder().on<ConnectionError>(
      strategies: [
        When(
          any,
          repeat: 1,
          withInterval: (_) => Duration(milliseconds: 200),
        ),
      ],
    ).on<ServerError>(
      strategies: [
        When(
          any,
          repeat: 3,
          withInterval: (attempt) => Duration(
            milliseconds: 200 * pow(2, attempt),
          ),
        ),
      ],
    ).on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: _accountService.refreshAccessToken,
        ),
      ],
    ).build();
  }

  Future<FeedArticlesVm> loadArticles(ArticleFilter filter, int page) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var articles = await _policy.execute(
        () => _feedApiService.getArticlesForTeam(
          currentTeam.id,
          filter,
          page,
        ),
      );

      _storage.addFeedArticles(
        FeedArticlesVm(
          page: page,
          articles: articles.map((a) => ArticleVm.fromDto(a)).toList(),
        ),
      );
    } catch (error) {
      _notificationService.showMessage(error.toString());
    }

    return _storage.getFeedArticles();
  }

  Future<Either<Error, ArticleVm>> loadArticle(int articleId) async {
    try {
      var article = await _policy.execute(
        () => _feedApiService.getArticle(articleId),
      );

      return Right(ArticleVm.fromDto(article));
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return Left(Error(error.toString()));
    }
  }

  Future<Option<VideoDataVm>> processVideoUrl(String url) async {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      var videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        try {
          // @@TODO: Try multiple thumbnail urls.
          var thumbnailFile = await _imageService.downloadImage(
            'https://i.ytimg.com/vi/$videoId/mqdefault.jpg',
          );

          return Some(VideoDataVm(
            isYoutubeVideo: true,
            thumbnailBytes: await thumbnailFile.readAsBytes(),
            videoUrl: url,
          ));
        } catch (error) {
          // @@TODO: Log properly.
          print(error.toString());
        }
      }

      _notificationService.showMessage('Invalid youtube video url');
    } else {
      _notificationService.showMessage(
        'Not Implemented. Currently only youtube videos are supported',
      );
    }

    return None();
  }

  Future<bool> postVideoArticle(
    ArticleType type,
    String title,
    Uint8List thumbnailBytes,
    String videoUrl,
    String summary,
  ) async {
    // @@TODO: Validation.
    bool valid = true;
    if (!valid) {
      _notificationService.showMessage('Invalid input');
      return false;
    }

    try {
      var currentTeam = await _storage.loadCurrentTeam();

      _notificationService.showMessage(
        'The article has been submitted for review',
      );

      await _policy.execute(
        () => _feedApiService.postVideoArticle(
          currentTeam.id,
          type,
          title,
          thumbnailBytes,
          summary,
          videoUrl,
        ),
      );

      return true;
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return false;
    }
  }

  Future<bool> saveArticlePreview(
    String title,
    String previewImageUrl,
    String summary,
  ) async {
    // @@TODO: Validation.
    bool valid = true;
    if (valid) {
      _title = title;
      _previewImageUrl = previewImageUrl;
      _summary = summary;
    } else {
      _notificationService.showMessage('Invalid input');
    }

    return valid;
  }

  List<dynamic> loadArticleContent() => _content;

  void saveArticleContent(List<dynamic> content) {
    _content = content;
  }

  void _clearArticleData() {
    _title = null;
    _previewImageUrl = null;
    _summary = null;
    _content = null;
  }

  Future<bool> postArticle(ArticleType type, List<dynamic> content) async {
    // @@TODO: Validation.
    bool valid = true;
    if (!valid) {
      _notificationService.showMessage('Invalid input');
      return false;
    }

    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var contentString = jsonEncode(content);

      _notificationService.showMessage(
        'The article has been submitted for review',
      );

      await _policy.execute(
        () => _feedApiService.postArticle(
          currentTeam.id,
          type,
          _title,
          _previewImageUrl,
          _summary,
          contentString,
        ),
      );

      _clearArticleData();

      return true;
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return false;
    }
  }

  Future<FeedArticlesVm> voteForArticle(int articleId, int userVote) async {
    try {
      var articleRating = await _policy.execute(
        () => _feedApiService.voteForArticle(articleId, userVote),
      );

      var feedArticles = _storage.getFeedArticles().copy();
      var articles = feedArticles.articles;
      var index = articles.indexWhere((a) => a.id == articleId);
      if (index >= 0) {
        articles[index] = articles[index].copyWith(
          rating: articleRating.rating,
          userVote: userVote,
        );

        _storage.setFeedArticles(feedArticles);
      }
    } catch (error) {
      _notificationService.showMessage(error.toString());
    }

    return _storage.getFeedArticles();
  }

  Future<List<CommentVm>> loadComments(int articleId) async {
    try {
      var commentDtos = await _policy.execute(
        () => _feedApiService.getCommentsForArticle(articleId),
      );

      var comments = commentDtos.map((c) => CommentVm.fromDto(c)).toList();

      var rootCommentsWithDescendants =
          comments.where((comment) => comment.parentId == null).toList()
            ..forEach(
              (rootComment) {
                var threadComments =
                    comments.where((c) => c.rootId == rootComment.id).toList();

                var queue = Queue<CommentVm>();
                queue.add(rootComment);
                while (queue.isNotEmpty) {
                  var comment = queue.removeFirst();
                  var childComments = threadComments.where(
                    (c) => c.parentId == comment.id,
                  );
                  comment.children.addAll(childComments);
                  queue.addAll(childComments);
                }
              },
            );

      _storage.setArticleComments(
        ArticleCommentsVm(
          articleId: articleId,
          comments: rootCommentsWithDescendants,
        ),
      );
    } catch (error) {
      _notificationService.showMessage(error.toString());
    }

    return _storage.getArticleComments().comments;
  }

  Future<List<CommentVm>> voteForComment(
    int articleId,
    String commentId,
    String commentPath,
    int userVote,
  ) async {
    try {
      var commentRating = await _policy.execute(
        () => _feedApiService.voteForComment(articleId, commentId, userVote),
      );

      var articleComments = _storage.getArticleComments();
      if (articleComments.articleId == articleId) {
        var rootCommentsWithDescendants = articleComments.comments
            .map((comment) => comment.deepCopy())
            .toList();

        var comments = rootCommentsWithDescendants;
        var ancestorCommentIds = commentPath.split('<-')..removeLast();
        for (var ancestorCommentId in ancestorCommentIds) {
          comments = comments
              ?.singleWhere(
                (comment) => comment.id == ancestorCommentId,
                orElse: () => null,
              )
              ?.children;
        }

        var index = comments?.indexWhere((c) => c.id == commentId);
        if (index != null && index >= 0) {
          comments[index] = comments[index].copyWith(
            rating: commentRating.rating,
            userVote: userVote,
          );

          _storage.setArticleComments(
            ArticleCommentsVm(
              articleId: articleId,
              comments: rootCommentsWithDescendants,
            ),
          );
        }
      }
    } catch (error) {
      _notificationService.showMessage(error.toString());
    }

    return _storage.getArticleComments().comments;
  }

  Future<Tuple2<CommentVm, List<CommentVm>>> postComment(
    int articleId,
    String commentPath,
    String body,
  ) async {
    // @@TODO: Validation.
    CommentVm postedComment;
    try {
      var result = await _accountService.loadAccount();
      var username = result.fold(
        (error) => null,
        (account) => account.username,
      );

      // @@TODO: Deal with error (username == null).

      String rootCommentId;
      String parentCommentId;
      if (commentPath != null) {
        var ancestorCommentIds = commentPath.split('<-');
        rootCommentId = ancestorCommentIds.first;
        parentCommentId = ancestorCommentIds.last;
      }

      var commentId = await _policy.execute(
        () => _feedApiService.postComment(
          articleId,
          rootCommentId,
          parentCommentId,
          body,
        ),
      );

      postedComment = CommentVm(
        id: commentId,
        rootId: rootCommentId ?? commentId,
        parentId: parentCommentId,
        authorId: null,
        authorUsername: username,
        postedAt: DateTime.fromMillisecondsSinceEpoch(
          Ulid.parse(commentId).toMillis(),
        ),
        rating: 0,
        body: body,
        userVote: null,
      );

      var articleComments = _storage.getArticleComments();
      if (articleComments.articleId == articleId) {
        var rootCommentsWithDescendants = articleComments.comments
            .map((comment) => comment.deepCopy())
            .toList();

        if (commentPath == null) {
          rootCommentsWithDescendants.add(postedComment);
        } else {
          var siblingComments = rootCommentsWithDescendants;
          var ancestorCommentIds = commentPath.split('<-');
          for (var ancestorCommentId in ancestorCommentIds) {
            siblingComments = siblingComments
                .singleWhere(
                  (comment) => comment.id == ancestorCommentId,
                  orElse: () => null,
                )
                ?.children;

            if (siblingComments == null) {
              postedComment = null;
              throw Error('The specified comment thread has been deleted');
            }
          }

          siblingComments.add(postedComment);
        }

        _storage.setArticleComments(
          ArticleCommentsVm(
            articleId: articleId,
            comments: rootCommentsWithDescendants,
          ),
        );
      }
    } catch (error) {
      _notificationService.showMessage(error.toString());
    }

    return Tuple2(postedComment, _storage.getArticleComments().comments);
  }
}
