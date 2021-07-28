import 'dart:convert';

import '../dto/fixture_performance_ratings_dto.dart';
import '../../persistence/tables/fixture_performance_ratings_table.dart';
import 'performance_rating_entity.dart';

class FixturePerformanceRatingsEntity {
  final int fixtureId;
  final int teamId;
  final bool isFinalized;
  final List<PerformanceRatingEntity> performanceRatings;

  FixturePerformanceRatingsEntity.fromMap(Map<String, dynamic> map)
      : fixtureId = map[FixturePerformanceRatingsTable.fixtureId],
        teamId = map[FixturePerformanceRatingsTable.teamId],
        isFinalized = map[FixturePerformanceRatingsTable.isFinalized] == 1,
        performanceRatings = map[
                    FixturePerformanceRatingsTable.performanceRatings] !=
                null
            ? (jsonDecode(
                        map[FixturePerformanceRatingsTable.performanceRatings])
                    as List<dynamic>)
                .map((ratingMap) => PerformanceRatingEntity.fromMap(ratingMap))
                .toList()
            : null;

  FixturePerformanceRatingsEntity.empty(int fixtureId, int teamId)
      : fixtureId = fixtureId,
        teamId = teamId,
        isFinalized = false,
        performanceRatings = null;

  FixturePerformanceRatingsEntity.fromDto(
    int teamId,
    FixturePerformanceRatingsDto fixturePerformanceRatings,
  )   : fixtureId = fixturePerformanceRatings.fixtureId,
        teamId = teamId,
        isFinalized = fixturePerformanceRatings.isFinalized,
        performanceRatings = fixturePerformanceRatings.performanceRatings
            ?.map((pr) => PerformanceRatingEntity.fromDto(pr))
            ?.toList();

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[FixturePerformanceRatingsTable.fixtureId] = fixtureId;
    map[FixturePerformanceRatingsTable.teamId] = teamId;
    map[FixturePerformanceRatingsTable.isFinalized] = isFinalized ? 1 : 0;
    map[FixturePerformanceRatingsTable.performanceRatings] =
        performanceRatings != null ? jsonEncode(performanceRatings) : null;

    return map;
  }
}
