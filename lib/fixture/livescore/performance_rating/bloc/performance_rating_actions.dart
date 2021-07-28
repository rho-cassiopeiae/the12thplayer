import 'package:flutter/foundation.dart';

abstract class PerformanceRatingAction {}

class LoadPerformanceRatings extends PerformanceRatingAction {
  final int fixtureId;

  LoadPerformanceRatings({@required this.fixtureId});
}

class RateParticipantOfGivenFixture extends PerformanceRatingAction {
  final int fixtureId;
  final String participantIdentifier;
  final double rating;

  RateParticipantOfGivenFixture({
    @required this.fixtureId,
    @required this.participantIdentifier,
    @required this.rating,
  });
}
