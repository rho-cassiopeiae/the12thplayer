import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'feed_states.dart';
import 'feed_actions.dart';
import '../services/feed_service.dart';
import '../../general/bloc/bloc.dart';

class FeedBloc extends Bloc<FeedAction> {
  final FeedService _feedService;

  BehaviorSubject<VoteForArticle> _voteActionChannel =
      BehaviorSubject<VoteForArticle>();

  BehaviorSubject<LoadArticlesState> _feedArticlesStateChannel =
      BehaviorSubject<LoadArticlesState>();
  Stream<LoadArticlesState> get feedArticlesState$ =>
      _feedArticlesStateChannel.stream;

  FeedBloc(this._feedService) {
    actionChannel.stream.listen((action) {
      if (action is LoadArticles) {
        _loadArticles(action);
      } else if (action is LoadArticle) {
        _loadArticle(action);
      } else if (action is ProcessVideoUrl) {
        _processVideoUrl(action);
      } else if (action is PostVideoArticle) {
        _postVideoArticle(action);
      } else if (action is SaveArticlePreview) {
        _saveArticlePreview(action);
      } else if (action is LoadArticleContent) {
        _loadArticleContent(action);
      } else if (action is SaveArticleContent) {
        _saveArticleContent(action);
      } else if (action is PostArticle) {
        _postArticle(action);
      } else if (action is VoteForArticle) {
        _voteActionChannel.add(action);
      }
    });

    _voteActionChannel
        .debounceTime(Duration(seconds: 1))
        .listen((action) => _voteForArticle(action));
  }

  @override
  void dispose({FeedAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _voteActionChannel.close();
    _voteActionChannel = null;
    _feedArticlesStateChannel.close();
    _feedArticlesStateChannel = null;
  }

  void _loadArticles(LoadArticles action) async {
    var feedArticles = await _feedService.loadArticles(
      action.filter,
      action.page,
    );

    var state = ArticlesReady(feedArticles: feedArticles);

    action.complete(state);
    _feedArticlesStateChannel?.add(state);
  }

  void _loadArticle(LoadArticle action) async {
    var result = await _feedService.loadArticle(action.articleId);

    var state = result.fold(
      (error) => ArticleError(),
      (article) => ArticleReady(article: article),
    );

    action.complete(state);
  }

  void _processVideoUrl(ProcessVideoUrl action) async {
    var result = await _feedService.processVideoUrl(action.url);

    var state = result.fold(
      () => VideoUrlProcessingFailed(),
      (videoData) => VideoUrlProcessingSucceeded(videoData: videoData),
    );

    action.complete(state);
  }

  void _postVideoArticle(PostVideoArticle action) async {
    bool posted = await _feedService.postVideoArticle(
      action.type,
      action.title,
      action.thumbnailBytes,
      action.videoUrl,
      action.summary,
    );

    if (posted) {
      action.complete(ArticlePostingSucceeded());
    } else {
      action.complete(ArticlePostingFailed());
    }
  }

  void _saveArticlePreview(SaveArticlePreview action) async {
    bool saved = await _feedService.saveArticlePreview(
      action.title,
      action.previewImageUrl,
      action.summary,
    );

    if (saved) {
      action.complete(ArticlePreviewSavingSucceeded());
    } else {
      action.complete(ArticlePreviewSavingFailed());
    }
  }

  void _loadArticleContent(LoadArticleContent action) {
    List<dynamic> content = _feedService.loadArticleContent();
    action.complete(ArticleContentReady(content: content));
  }

  void _saveArticleContent(SaveArticleContent action) {
    _feedService.saveArticleContent(action.content);
    action.complete(ArticleContentSavingSucceeded());
  }

  void _postArticle(PostArticle action) async {
    bool posted = await _feedService.postArticle(
      action.type,
      action.content,
    );

    if (posted) {
      action.complete(ArticlePostingSucceeded());
    } else {
      action.complete(ArticlePostingFailed());
    }
  }

  void _voteForArticle(VoteForArticle action) async {
    var feedArticles = await _feedService.voteForArticle(
      action.articleId,
      action.userVote,
    );

    _feedArticlesStateChannel?.add(ArticlesReady(feedArticles: feedArticles));
  }
}
