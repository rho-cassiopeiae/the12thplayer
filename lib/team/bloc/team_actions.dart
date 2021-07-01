import 'dart:async';

import 'package:flutter/foundation.dart';

import 'team_states.dart';

abstract class TeamAction {}

abstract class TeamActionFutureState<TState extends TeamState>
    extends TeamAction {
  final Completer<TState> _stateReady = Completer<TState>();
  Future<TState> get state => _stateReady.future;

  void complete(TState state) => _stateReady.complete(state);
}

class CheckSomeTeamSelected
    extends TeamActionFutureState<CheckSomeTeamSelectedResult> {}

class LoadTeamsWithCommunities extends TeamAction {}

class SelectTeam extends TeamActionFutureState<SelectTeamReady> {
  final int teamId;
  final String teamName;
  final String teamLogoUrl;

  SelectTeam({
    @required this.teamId,
    @required this.teamName,
    @required this.teamLogoUrl,
  });
}

class LoadTeamSquad extends TeamAction {}

class LoadPlayerPerformanceRatings extends TeamAction {
  final int playerId;

  LoadPlayerPerformanceRatings({@required this.playerId});
}

class LoadManagerPerformanceRatings extends TeamAction {
  final int managerId;

  LoadManagerPerformanceRatings({@required this.managerId});
}
