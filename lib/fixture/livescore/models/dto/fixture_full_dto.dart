import '../../../common/models/dto/fixture_summary_dto.dart';
import '../../../common/models/dto/performance_rating_dto.dart';
import '../../../common/models/dto/team_color_dto.dart';
import '../../../common/models/dto/team_lineup_dto.dart';
import '../../../common/models/dto/team_match_events_dto.dart';
import '../../../common/models/dto/team_stats_dto.dart';

class FixtureFullDto extends FixtureSummaryDto {
  final String refereeName;
  final Iterable<TeamColorDto> colors;
  final Iterable<TeamLineupDto> lineups;
  final Iterable<TeamMatchEventsDto> events;
  final Iterable<TeamStatsDto> stats;
  final Iterable<PerformanceRatingDto> performanceRatings;
  final bool isCompletedAndInactive;
  final bool shouldSubscribe;

  FixtureFullDto.fromMap(Map<String, dynamic> map)
      : refereeName = map['refereeName'],
        colors = (map['colors'] as List<dynamic>)
            .map((colorMap) => TeamColorDto.fromMap(colorMap)),
        lineups = (map['lineups'] as List<dynamic>)
            .map((lineupMap) => TeamLineupDto.fromMap(lineupMap)),
        events = (map['events'] as List<dynamic>)
            .map((eventsMap) => TeamMatchEventsDto.fromMap(eventsMap)),
        stats = (map['stats'] as List<dynamic>)
            .map((statsMap) => TeamStatsDto.fromMap(statsMap)),
        performanceRatings = (map['performanceRatings'] as List<dynamic>)
            .map((ratingMap) => PerformanceRatingDto.fromMap(ratingMap)),
        isCompletedAndInactive = map['isCompletedAndInactive'],
        shouldSubscribe = map['shouldSubscribe'],
        super.fromMap(map);

  List<PerformanceRatingDto> buildPerformanceRatingsFromLineupAndEvents(
    int teamId,
  ) {
    var performanceRatings = <PerformanceRatingDto>[];

    var lineup = lineups.firstWhere((lineup) => lineup.teamId == teamId);

    if (lineup.manager != null) {
      performanceRatings.add(
        PerformanceRatingDto(
          participantIdentifier: 'manager:${lineup.manager.id}',
        ),
      );
    }

    lineup.startingXI?.forEach(
      (player) => performanceRatings.add(
        PerformanceRatingDto(
          participantIdentifier: 'player:${player.id}',
        ),
      ),
    );

    var events = this.events.firstWhere((events) => events.teamId == teamId);
    events.events?.forEach((event) {
      if (event.type == 'substitution' && event.playerId != null) {
        performanceRatings.add(
          PerformanceRatingDto(
            participantIdentifier: 'player:${event.playerId}',
          ),
        );
      }
    });

    return performanceRatings;
  }
}
