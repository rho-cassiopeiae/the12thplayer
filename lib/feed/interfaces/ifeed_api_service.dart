import 'dart:typed_data';

import '../enums/article_type.dart';
import '../models/dto/team_feed_update_dto.dart';

abstract class IFeedApiService {
  Future<Stream<TeamFeedUpdateDto>> subscribeToTeamFeed(int teamId);

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
