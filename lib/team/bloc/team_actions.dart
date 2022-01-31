import 'package:flutter/foundation.dart';

abstract class TeamAction {}

class LoadTeamSquad extends TeamAction {}

class LoadPlayerRatings extends TeamAction {
  final int playerId;

  LoadPlayerRatings({@required this.playerId});
}

class LoadManagerRatings extends TeamAction {
  final int managerId;

  LoadManagerRatings({@required this.managerId});
}
