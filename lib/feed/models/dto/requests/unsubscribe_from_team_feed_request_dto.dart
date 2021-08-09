import 'package:flutter/foundation.dart';

class UnsubscribeFromTeamFeedRequestDto {
  final int teamId;

  UnsubscribeFromTeamFeedRequestDto({@required this.teamId});

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['teamId'] = teamId;

    return map;
  }
}
