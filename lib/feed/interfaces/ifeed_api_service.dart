import 'dart:typed_data';

import '../models/dto/comment_rating_dto.dart';
import '../models/dto/article_rating_dto.dart';
import '../models/dto/comment_dto.dart';
import '../enums/article_filter.dart';
import '../models/dto/article_dto.dart';
import '../enums/article_type.dart';

abstract class IFeedApiService {
  Future<Iterable<ArticleDto>> getArticlesForTeam(
    int teamId,
    ArticleFilter filter,
    int page,
  );

  Future<ArticleDto> getArticle(int articleId);

  Future postVideoArticle(
    int teamId,
    ArticleType type,
    String title,
    Uint8List thumbnailBytes,
    String summary,
    String videoUrl,
  );

  Future postArticle(
    int teamId,
    ArticleType type,
    String title,
    String previewImageUrl,
    String summary,
    String content,
  );

  Future<ArticleRatingDto> voteForArticle(int articleId, int userVote);

  Future<Iterable<CommentDto>> getCommentsForArticle(int articleId);

  Future<CommentRatingDto> voteForComment(
    int articleId,
    String commentId,
    int userVote,
  );

  Future<String> postComment(
    int articleId,
    String rootCommentId,
    String parentCommentId,
    String body,
  );
}
