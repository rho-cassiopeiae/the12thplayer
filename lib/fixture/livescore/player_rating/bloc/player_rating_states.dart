import 'package:flutter/foundation.dart';

import '../models/vm/player_ratings_vm.dart';

abstract class PlayerRatingState {}

abstract class LoadPlayerRatingsState extends PlayerRatingState {}

class PlayerRatingsLoading extends LoadPlayerRatingsState {}

class PlayerRatingsReady extends LoadPlayerRatingsState {
  final PlayerRatingsVm playerRatings;

  PlayerRatingsReady({@required this.playerRatings});
}

class PlayerRatingsError extends LoadPlayerRatingsState {}
