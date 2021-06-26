import 'discussion_entry_dto.dart';

class FixtureDiscussionUpdateDto {
  final int fixtureId;
  final int teamId;
  final String discussionIdentifier;
  final Iterable<DiscussionEntryDto> entries;
  final bool shouldSubscribe;

  FixtureDiscussionUpdateDto.fromMap(Map<String, dynamic> map)
      : fixtureId = map['fixtureId'],
        teamId = map['teamId'],
        discussionIdentifier = map['discussionIdentifier'],
        entries = (map['entries'] as List<dynamic>)
            .map((entryMap) => DiscussionEntryDto.fromMap(entryMap)),
        shouldSubscribe = map['shouldSubscribe'];
}
