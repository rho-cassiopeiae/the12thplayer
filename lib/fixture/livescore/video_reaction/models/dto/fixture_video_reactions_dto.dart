import 'video_reaction_dto.dart';

class FixtureVideoReactionsDto {
  final int fixtureId;
  final Iterable<VideoReactionDto> reactions;

  FixtureVideoReactionsDto.fromMap(Map<String, dynamic> map)
      : fixtureId = map['fixtureId'],
        reactions = (map['reactions'] as List<dynamic>)
            .map((reactionMap) => VideoReactionDto.fromMap(reactionMap));
}
