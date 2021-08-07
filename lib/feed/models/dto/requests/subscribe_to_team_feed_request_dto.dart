import 'package:flutter/foundation.dart';

class SubscribeToTeamFeedRequestDto {
  final int teamId;

  SubscribeToTeamFeedRequestDto({@required this.teamId});

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['teamId'] = teamId;

    return map;
  }
}
