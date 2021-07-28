import 'package:flutter/foundation.dart';

import '../dto/performance_rating_dto.dart';

class PerformanceRatingEntity {
  final String participantIdentifier;
  final int totalRating;
  final int totalVoters;
  final double myRating;

  PerformanceRatingEntity._({
    @required this.participantIdentifier,
    @required this.totalRating,
    @required this.totalVoters,
    @required this.myRating,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['participantIdentifier'] = participantIdentifier;
    map['totalRating'] = totalRating;
    map['totalVoters'] = totalVoters;
    map['myRating'] = myRating;

    return map;
  }

  PerformanceRatingEntity.fromMap(Map<String, dynamic> map)
      : participantIdentifier = map['participantIdentifier'],
        totalRating = map['totalRating'],
        totalVoters = map['totalVoters'],
        myRating = map['myRating'];

  PerformanceRatingEntity.fromDto(PerformanceRatingDto performanceRating)
      : participantIdentifier = performanceRating.participantIdentifier,
        totalRating = performanceRating.totalRating,
        totalVoters = performanceRating.totalVoters,
        myRating = performanceRating.myRating;

  PerformanceRatingEntity copyWith({
    @required int totalRating,
    @required int totalVoters,
    @required double myRating,
  }) =>
      PerformanceRatingEntity._(
        participantIdentifier: participantIdentifier,
        totalRating: totalRating,
        totalVoters: totalVoters,
        myRating: myRating,
      );
}
