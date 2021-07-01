import '../models/dto/team_dto.dart';
import '../models/dto/fixture_performance_rating_dto.dart';
import '../models/dto/team_squad_dto.dart';

abstract class ITeamApiService {
  Future<Iterable<TeamDto>> getTeamsWithCommunities();

  Future<TeamSquadDto> getTeamSquad(int teamId);

  Future<Iterable<FixturePerformanceRatingDto>> getTeamPlayerPerformanceRatings(
    int teamId,
    int playerId,
  );

  Future<Iterable<FixturePerformanceRatingDto>>
      getTeamManagerPerformanceRatings(
    int teamId,
    int managerId,
  );
}
