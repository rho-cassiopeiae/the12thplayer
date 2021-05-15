import 'package:flutter/foundation.dart';

abstract class TeamAction {}

class LoadTeamSquad extends TeamAction {}

class LoadPlayerPerformanceRatings extends TeamAction {
  final int playerId;

  LoadPlayerPerformanceRatings({@required this.playerId});
}

class LoadManagerPerformanceRatings extends TeamAction {
  final int managerId;

  LoadManagerPerformanceRatings({@required this.managerId});
}
