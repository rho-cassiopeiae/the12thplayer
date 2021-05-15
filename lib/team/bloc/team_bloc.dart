import 'dart:async';

import '../../general/bloc/bloc.dart';
import '../services/team_service.dart';
import 'team_actions.dart';
import 'team_states.dart';

class TeamBloc extends Bloc<TeamAction> {
  final TeamService _teamService;

  StreamController<TeamSquadState> _squadStateChannel =
      StreamController<TeamSquadState>.broadcast();
  Stream<TeamSquadState> get squadState$ => _squadStateChannel.stream;

  StreamController<TeamMemberState> _memberStateChannel =
      StreamController<TeamMemberState>.broadcast();
  Stream<TeamMemberState> get memberState$ => _memberStateChannel.stream;

  TeamBloc(this._teamService) {
    actionChannel.stream.listen((action) {
      if (action is LoadTeamSquad) {
        _loadTeamSquad(action);
      } else if (action is LoadPlayerPerformanceRatings) {
        _loadPlayerPerformanceRatings(action);
      } else if (action is LoadManagerPerformanceRatings) {
        _loadManagerPerformanceRatings(action);
      }
    });
  }

  @override
  void dispose({TeamAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _squadStateChannel.close();
    _squadStateChannel = null;
    _memberStateChannel.close();
    _memberStateChannel = null;
  }

  void _loadTeamSquad(LoadTeamSquad action) async {
    var result = await _teamService.loadTeamSquad();

    var state = result.fold(
      (error) => TeamSquadError(message: error.toString()),
      (teamSquad) => TeamSquadReady(teamSquad: teamSquad),
    );

    _squadStateChannel?.add(state);
  }

  void _loadPlayerPerformanceRatings(
    LoadPlayerPerformanceRatings action,
  ) async {
    var result = await _teamService.loadPlayerPerformanceRatings(
      action.playerId,
    );

    var state = result.fold(
      (error) => TeamMemberError(message: error.toString()),
      (performanceRatings) =>
          TeamMemberReady(performanceRatings: performanceRatings),
    );

    _memberStateChannel?.add(state);
  }

  void _loadManagerPerformanceRatings(
    LoadManagerPerformanceRatings action,
  ) async {
    var result = await _teamService.loadManagerPerformanceRatings(
      action.managerId,
    );

    var state = result.fold(
      (error) => TeamMemberError(message: error.toString()),
      (performanceRatings) =>
          TeamMemberReady(performanceRatings: performanceRatings),
    );

    _memberStateChannel?.add(state);
  }
}
