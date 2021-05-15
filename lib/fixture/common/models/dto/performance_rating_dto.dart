import 'package:flutter/foundation.dart';

class PerformanceRatingDto {
  final String participantIdentifier;
  final int totalRating;
  final int totalVoters;

  PerformanceRatingDto({
    @required this.participantIdentifier,
    this.totalRating,
    this.totalVoters,
  });

  PerformanceRatingDto.fromMap(Map<String, dynamic> map)
      : participantIdentifier = map['participantIdentifier'],
        totalRating = map['totalRating'],
        totalVoters = map['totalVoters'];
}
