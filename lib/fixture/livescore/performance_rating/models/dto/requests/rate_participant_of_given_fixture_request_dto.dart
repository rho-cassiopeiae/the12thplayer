import 'package:flutter/foundation.dart';

class RateParticipantOfGivenFixtureRequestDto {
  final int fixtureId;
  final int teamId;
  final String participantIdentifier;
  final double rating;

  RateParticipantOfGivenFixtureRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.participantIdentifier,
    @required this.rating,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['participantIdentifier'] = participantIdentifier;
    map['rating'] = rating;

    return map;
  }
}
