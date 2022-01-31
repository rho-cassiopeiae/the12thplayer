import 'already_started_fixture_dto.dart';

class MatchPredictionsSubmissionDto {
  final Map<String, String> updatedPredictions;
  final Iterable<AlreadyStartedFixtureDto> alreadyStartedFixtures;

  MatchPredictionsSubmissionDto.fromMap(Map<String, dynamic> map)
      : updatedPredictions = map.containsKey('updatedPredictions')
            ? Map<String, String>.from(map['updatedPredictions'])
            : null,
        alreadyStartedFixtures = map.containsKey('alreadyStartedFixtures')
            ? (map['alreadyStartedFixtures'] as List).map(
                (fixtureMap) => AlreadyStartedFixtureDto.fromMap(fixtureMap),
              )
            : null;
}
