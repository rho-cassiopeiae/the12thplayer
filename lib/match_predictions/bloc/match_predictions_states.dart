import 'package:flutter/foundation.dart';

import '../models/vm/active_season_round_with_fixtures_vm.dart';

abstract class MatchPredictionsState {}

abstract class LoadActiveFixturesState extends MatchPredictionsState {}

class ActiveFixturesLoading extends LoadActiveFixturesState {}

class ActiveFixturesReady extends LoadActiveFixturesState {
  final ActiveSeasonRoundWithFixturesVm seasonRound;

  ActiveFixturesReady({@required this.seasonRound});
}
