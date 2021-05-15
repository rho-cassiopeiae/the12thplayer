import '../../common/models/entities/fixture_entity.dart';

abstract class IFixtureRepository {
  Future<FixtureEntity> loadFixtureForTeam(int fixtureId, int teamId);

  Future<FixtureEntity> updateFixture(FixtureEntity fixture);

  Future<FixtureEntity> updateFixtureFromLivescore(
    FixtureEntity fixture,
  );

  Future<double> updateMyRatingOfParticipantOfGivenFixture(
    int fixtureId,
    int teamId,
    String participantIdentifier,
    double rating,
  );

  Future updateRatingOfParticipantOfGivenFixture(
    int fixtureId,
    int teamId,
    String participantIdentifier,
    int totalRating,
    int totalVoters,
  );
}
