import '../dto/performance_rating_dto.dart';

class PerformanceRatingEntity {
  final String participantIdentifier;
  final double myRating;
  final int totalRating;
  final int totalVoters;

  PerformanceRatingEntity._(
    this.participantIdentifier,
    this.myRating,
    this.totalRating,
    this.totalVoters,
  );

  PerformanceRatingEntity copyWith({
    double myRating,
    int totalRating,
    int totalVoters,
  }) {
    return PerformanceRatingEntity._(
      participantIdentifier,
      myRating ?? this.myRating,
      totalRating ?? this.totalRating,
      totalVoters ?? this.totalVoters,
    );
  }

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['participantIdentifier'] = participantIdentifier;
    map['myRating'] = myRating;
    map['totalRating'] = totalRating;
    map['totalVoters'] = totalVoters;

    return map;
  }

  PerformanceRatingEntity.fromMap(Map<String, dynamic> map)
      : participantIdentifier = map['participantIdentifier'],
        myRating = map['myRating'],
        totalRating = map['totalRating'],
        totalVoters = map['totalVoters'];

  PerformanceRatingEntity.fromDto(PerformanceRatingDto performanceRating)
      : participantIdentifier = performanceRating.participantIdentifier,
        myRating = null,
        totalRating = performanceRating.totalRating,
        totalVoters = performanceRating.totalVoters;
}
