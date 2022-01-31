import 'package:flutter/foundation.dart';

import '../models/vm/fixture_player_rating_vm.dart';
import '../models/vm/team_squad_vm.dart';

abstract class TeamState {}

abstract class LoadTeamSquadState extends TeamState {}

class TeamSquadLoading extends LoadTeamSquadState {}

class TeamSquadReady extends LoadTeamSquadState {
  final TeamSquadVm teamSquad;

  TeamSquadReady({@required this.teamSquad});
}

abstract class LoadTeamMemberState extends TeamState {}

class TeamMemberLoading extends LoadTeamMemberState {}

class TeamMemberReady extends LoadTeamMemberState {
  final List<FixturePlayerRatingVm> ratings;

  TeamMemberReady({@required this.ratings});
}
