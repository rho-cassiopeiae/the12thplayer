import '../models/entities/fixture_player_ratings_entity.dart';

abstract class IPlayerRatingRepository {
  Future<FixturePlayerRatingsEntity> loadPlayerRatingsForFixture(
    int fixtureId,
    int teamId,
  );

  Future savePlayerRatingsForFixture(
    FixturePlayerRatingsEntity fixturePlayerRatings,
  );

  Future<FixturePlayerRatingsEntity> updatePlayerRating(
    int fixtureId,
    int teamId,
    String participantKey,
    int totalRating,
    int totalVoters,
    double userRating,
  );
}
