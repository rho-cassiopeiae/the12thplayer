import 'package:flutter/foundation.dart';

class RatePlayerRequestDto {
  final int fixtureId;
  final int teamId;
  final String participantKey;
  final double rating;

  RatePlayerRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.participantKey,
    @required this.rating,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['participantKey'] = participantKey;
    map['rating'] = rating;

    return map;
  }
}
