import 'discussion_dto.dart';

class FixtureDiscussionsDto {
  final int fixtureId;
  final Iterable<DiscussionDto> discussions;

  FixtureDiscussionsDto.fromMap(Map<String, dynamic> map)
      : fixtureId = map['fixtureId'],
        discussions = (map['discussions'] as List<dynamic>)
            .map((discussionMap) => DiscussionDto.fromMap(discussionMap));
}
