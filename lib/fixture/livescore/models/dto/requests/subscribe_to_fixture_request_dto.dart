import 'package:flutter/foundation.dart';

class SubscribeToFixtureRequestDto {
  final int fixtureId;
  final int teamId;

  SubscribeToFixtureRequestDto({
    @required this.fixtureId,
    @required this.teamId,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;

    return map;
  }
}
