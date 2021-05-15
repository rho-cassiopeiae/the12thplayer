import 'package:flutter/foundation.dart';

import '../models/vm/fixture_performance_rating_vm.dart';
import '../models/vm/team_squad_vm.dart';

abstract class TeamState {}

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
