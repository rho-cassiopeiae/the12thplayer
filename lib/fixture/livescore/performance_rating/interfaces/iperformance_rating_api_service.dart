import '../models/dto/performance_rating_dto.dart';
import '../models/dto/fixture_performance_ratings_dto.dart';

abstract class IPerformanceRatingApiService {
  Future<FixturePerformanceRatingsDto> getPerformanceRatingsForFixture(
    int fixtureId,
    int teamId,
  );

  Future<PerformanceRatingDto> rateParticipantOfGivenFixture(
    int fixtureId,
    int teamId,
    String participantIdentifier,
    double rating,
  );
}
