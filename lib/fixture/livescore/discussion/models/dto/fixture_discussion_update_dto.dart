import 'discussion_entry_dto.dart';

class FixtureDiscussionUpdateDto {
  final int fixtureId;
  final int teamId;
  final String discussionId;
  final Iterable<DiscussionEntryDto> entries;

  FixtureDiscussionUpdateDto.fromMap(Map<String, dynamic> map)
      : fixtureId = map['fixtureId'],
        teamId = map['teamId'],
        discussionId = map['discussionId'],
        entries = (map['entries'] as List)
            .map((entryMap) => DiscussionEntryDto.fromMap(entryMap));
}
