import '../models/dto/player_rating_dto.dart';
import '../models/dto/fixture_player_ratings_dto.dart';

abstract class IPlayerRatingApiService {
  Future<FixturePlayerRatingsDto> getPlayerRatingsForFixture(
    int fixtureId,
    int teamId,
  );

  Future<PlayerRatingDto> ratePlayer(
    int fixtureId,
    int teamId,
    String participantKey,
    double rating,
  );
}
