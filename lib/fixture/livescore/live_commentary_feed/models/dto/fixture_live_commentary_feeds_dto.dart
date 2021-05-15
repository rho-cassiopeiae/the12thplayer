import 'live_commentary_feed_dto.dart';

class FixtureLiveCommentaryFeedsDto {
  final int fixtureId;
  final bool ongoing;
  final Iterable<LiveCommentaryFeedDto> feeds;

  FixtureLiveCommentaryFeedsDto.fromMap(Map<String, dynamic> map)
      : fixtureId = map['fixtureId'],
        ongoing = map['ongoing'],
        feeds = (map['feeds'] as List<dynamic>)
            .map((feedMap) => LiveCommentaryFeedDto.fromMap(feedMap));
}
