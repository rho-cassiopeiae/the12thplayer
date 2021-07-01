import '../models/entities/team_entity.dart';

abstract class ITeamRepository {
  Future<TeamEntity> loadCurrentTeam();
  Future selectTeam(TeamEntity team);
}
