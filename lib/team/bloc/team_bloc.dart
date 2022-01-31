import 'dart:async';

import '../../general/bloc/bloc.dart';
import '../services/team_service.dart';
import 'team_actions.dart';
import 'team_states.dart';

class TeamBloc extends Bloc<TeamAction> {
  final TeamService _teamService;

  StreamController<LoadTeamSquadState> _teamSquadStateChannel =
      StreamController<LoadTeamSquadState>.broadcast();
  Stream<LoadTeamSquadState> get teamSquadState$ =>
      _teamSquadStateChannel.stream;

  StreamController<LoadTeamMemberState> _teamMemberStateChannel =
      StreamController<LoadTeamMemberState>.broadcast();
  Stream<LoadTeamMemberState> get teamMemberState$ =>
      _teamMemberStateChannel.stream;

  TeamBloc(this._teamService) {
    actionChannel.stream.listen((action) {
      if (action is LoadTeamSquad) {
        _loadTeamSquad(action);
      } else if (action is LoadPlayerRatings) {
        _loadPlayerRatings(action);
      } else if (action is LoadManagerRatings) {
        _loadManagerRatings(action);
      }
    });
  }

  @override
  void dispose({TeamAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _teamSquadStateChannel.close();
    _teamSquadStateChannel = null;
    _teamMemberStateChannel.close();
    _teamMemberStateChannel = null;
  }

  void _loadTeamSquad(LoadTeamSquad action) async {
    var teamSquad = await _teamService.loadTeamSquad();
    if (teamSquad != null) {
      _teamSquadStateChannel?.add(TeamSquadReady(teamSquad: teamSquad));
    }
  }

  void _loadPlayerRatings(LoadPlayerRatings action) async {
    var playerRatings = await _teamService.loadPlayerRatings(action.playerId);
    if (playerRatings != null) {
      _teamMemberStateChannel?.add(TeamMemberReady(ratings: playerRatings));
    }
  }

  void _loadManagerRatings(LoadManagerRatings action) async {
    var managerRatings = await _teamService.loadManagerRatings(
      action.managerId,
    );
    if (managerRatings != null) {
      _teamMemberStateChannel?.add(TeamMemberReady(ratings: managerRatings));
    }
  }
}
