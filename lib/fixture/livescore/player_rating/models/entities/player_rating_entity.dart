import 'package:flutter/foundation.dart';

import '../dto/player_rating_dto.dart';

class PlayerRatingEntity {
  final String participantKey;
  final int totalRating;
  final int totalVoters;
  final double userRating;

  PlayerRatingEntity._(
    this.participantKey,
    this.totalRating,
    this.totalVoters,
    this.userRating,
  );

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['participantKey'] = participantKey;
    map['totalRating'] = totalRating;
    map['totalVoters'] = totalVoters;
    map['userRating'] = userRating;

    return map;
  }

  PlayerRatingEntity.fromMap(Map<String, dynamic> map)
      : participantKey = map['participantKey'],
        totalRating = map['totalRating'],
        totalVoters = map['totalVoters'],
        userRating = map['userRating'];

  PlayerRatingEntity.fromDto(PlayerRatingDto playerRating)
      : participantKey = playerRating.participantKey,
        totalRating = playerRating.totalRating,
        totalVoters = playerRating.totalVoters,
        userRating = playerRating.userRating;

  PlayerRatingEntity copyWith({
    @required int totalRating,
    @required int totalVoters,
    @required double userRating,
  }) =>
      PlayerRatingEntity._(
        participantKey,
        totalRating,
        totalVoters,
        userRating,
      );
}
