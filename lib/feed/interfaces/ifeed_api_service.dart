import 'dart:typed_data';

import '../models/dto/article_dto.dart';
import '../enums/article_type.dart';
import '../models/dto/team_feed_update_dto.dart';

abstract class IFeedApiService {
  Future<Stream<TeamFeedUpdateDto>> subscribeToTeamFeed(int teamId);

  void unsubscribeFromTeamFeed(int teamId);

  Future<ArticleDto> getArticle(int teamId, DateTime postedAt);

  Future postVideoArticle(
    int teamId,
    ArticleType type,
    String title,
    Uint8List thumbnailBytes,
    String summary,
    String content,
  );

  Future postArticle(
    int teamId,
    ArticleType type,
    String title,
    String previewImageUrl,
    String summary,
    String content,
  );
}
