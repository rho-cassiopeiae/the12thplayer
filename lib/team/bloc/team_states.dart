import 'package:flutter/foundation.dart';

import '../models/vm/team_vm.dart';
import '../models/vm/fixture_performance_rating_vm.dart';
import '../models/vm/team_squad_vm.dart';

abstract class TeamState {}

class CheckSomeTeamSelectedResult extends TeamState {
  final bool selected;

  CheckSomeTeamSelectedResult({@required this.selected});
}

abstract class TeamsWithCommunitiesState extends TeamState {}

class TeamsWithCommunitiesLoading extends TeamsWithCommunitiesState {}

class TeamsWithCommunitiesReady extends TeamsWithCommunitiesState {
  final List<TeamVm> teams;

  TeamsWithCommunitiesReady({@required this.teams});
}

class TeamsWithCommunitiesError extends TeamsWithCommunitiesState {
  final String message;

  TeamsWithCommunitiesError({@required this.message});
}

class SelectTeamReady extends TeamState {}

abstract class TeamSquadState extends TeamState {}

class TeamSquadLoading extends TeamSquadState {}

class TeamSquadReady extends TeamSquadState {
  final TeamSquadVm teamSquad;

  TeamSquadReady({@required this.teamSquad});
}

class TeamSquadError extends TeamSquadState {
  final String message;

  TeamSquadError({@required this.message});
}

abstract class TeamMemberState extends TeamState {}

class TeamMemberLoading extends TeamMemberState {}

class TeamMemberReady extends TeamMemberState {
  final List<FixturePerformanceRatingVm> performanceRatings;

  TeamMemberReady({@required this.performanceRatings});
}

class TeamMemberError extends TeamMemberState {
  final String message;

  TeamMemberError({@required this.message});
}
