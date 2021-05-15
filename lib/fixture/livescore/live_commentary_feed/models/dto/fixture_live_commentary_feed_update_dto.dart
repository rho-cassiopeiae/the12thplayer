import 'live_commentary_feed_entry_dto.dart';

class FixtureLiveCommentaryFeedUpdateDto {
  final int fixtureId;
  final int teamId;
  final int authorId;
  final Iterable<LiveCommentaryFeedEntryDto> entries;

  FixtureLiveCommentaryFeedUpdateDto.fromMap(Map<String, dynamic> map)
      : fixtureId = map['fixtureId'],
        teamId = map['teamId'],
        authorId = map['authorId'],
        entries = (map['entries'] as List<dynamic>)
            .map((entryMap) => LiveCommentaryFeedEntryDto.fromMap(entryMap));
}
