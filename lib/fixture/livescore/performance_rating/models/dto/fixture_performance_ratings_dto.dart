import 'performance_rating_dto.dart';

class FixturePerformanceRatingsDto {
  final int fixtureId;
  final bool isFinalized;
  final Iterable<PerformanceRatingDto> performanceRatings;

  FixturePerformanceRatingsDto.fromMap(Map<String, dynamic> map)
      : fixtureId = map['fixtureId'],
        isFinalized = map['isFinalized'],
        performanceRatings = map['performanceRatings'] != null
            ? (map['performanceRatings'] as List<dynamic>)
                .map((ratingMap) => PerformanceRatingDto.fromMap(ratingMap))
            : null;
}
