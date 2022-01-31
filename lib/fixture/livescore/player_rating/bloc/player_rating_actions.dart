import 'package:flutter/foundation.dart';

abstract class PlayerRatingAction {}

class LoadPlayerRatings extends PlayerRatingAction {
  final int fixtureId;

  LoadPlayerRatings({@required this.fixtureId});
}

class RatePlayer extends PlayerRatingAction {
  final int fixtureId;
  final String participantKey;
  final double rating;

  RatePlayer({
    @required this.fixtureId,
    @required this.participantKey,
    @required this.rating,
  });
}
