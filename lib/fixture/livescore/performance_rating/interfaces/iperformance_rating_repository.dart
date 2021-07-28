import '../models/entities/fixture_performance_ratings_entity.dart';

abstract class IPerformanceRatingRepository {
  Future<FixturePerformanceRatingsEntity> loadPerformanceRatingsForFixture(
    int fixtureId,
    int teamId,
  );

  Future savePerformanceRatingsForFixture(
    FixturePerformanceRatingsEntity fixturePerformanceRatings,
  );

  Future<FixturePerformanceRatingsEntity>
      updatePerformanceRatingForFixtureParticipant(
    int fixtureId,
    int teamId,
    String participantIdentifier,
    int totalRating,
    int totalVoters,
    double myRating,
  );
}
