import '../models/dto/fixture_player_rating_dto.dart';
import '../models/dto/team_squad_dto.dart';

abstract class ITeamApiService {
  Future<TeamSquadDto> getTeamSquad(int teamId);

  Future<Iterable<FixturePlayerRatingDto>> getTeamPlayerRatings(
    int teamId,
    int playerId,
  );

  Future<Iterable<FixturePlayerRatingDto>> getTeamManagerRatings(
    int teamId,
    int managerId,
  );
}
