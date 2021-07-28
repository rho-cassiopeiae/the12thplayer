class PerformanceRatingDto {
  final String participantIdentifier;
  final int totalRating;
  final int totalVoters;
  final double myRating;

  PerformanceRatingDto.fromMap(Map<String, dynamic> map)
      : participantIdentifier = map['participantIdentifier'],
        totalRating = map['totalRating'],
        totalVoters = map['totalVoters'],
        myRating =
            map.containsKey('myRating') ? (map['myRating']).toDouble() : null;
}
