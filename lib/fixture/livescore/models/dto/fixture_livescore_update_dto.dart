import '../../../common/models/dto/discussion_dto.dart';
import '../../../common/models/dto/game_time_dto.dart';
import '../../../common/models/dto/performance_rating_dto.dart';
import '../../../common/models/dto/score_dto.dart';
import '../../../common/models/dto/team_color_dto.dart';
import '../../../common/models/dto/team_lineup_dto.dart';
import '../../../common/models/dto/team_match_events_dto.dart';
import '../../../common/models/dto/team_stats_dto.dart';

class FixtureLivescoreUpdateDto {
  final int fixtureId;
  final int teamId;
  final int startTime;
  final String status;
  final GameTimeDto gameTime;
  final ScoreDto score;
  final Iterable<TeamColorDto> colors;
  final Iterable<TeamLineupDto> lineups;
  final Iterable<TeamMatchEventsDto> events;
  final Iterable<TeamStatsDto> stats;
  final Iterable<DiscussionDto> discussions;

  FixtureLivescoreUpdateDto.fromMap(Map<String, dynamic> map)
      : fixtureId = map['fixtureId'],
        teamId = map['teamId'],
        startTime = map['startTime'],
        status = map['status'],
        gameTime = map['gameTime'] == null
            ? null
            : GameTimeDto.fromMap(map['gameTime']),
        score = map['score'] == null ? null : ScoreDto.fromMap(map['score']),
        colors = map['colors'] == null
            ? null
            : (map['colors'] as List<dynamic>)
                .map((colorMap) => TeamColorDto.fromMap(colorMap)),
        lineups = map['lineups'] == null
            ? null
            : (map['lineups'] as List<dynamic>)
                .map((lineupMap) => TeamLineupDto.fromMap(lineupMap)),
        events = map['events'] == null
            ? null
            : (map['events'] as List<dynamic>)
                .map((eventsMap) => TeamMatchEventsDto.fromMap(eventsMap)),
        stats = map['stats'] == null
            ? null
            : (map['stats'] as List<dynamic>)
                .map((statsMap) => TeamStatsDto.fromMap(statsMap)),
        discussions = (map['discussions'] as List<dynamic>)
            .map((discussionMap) => DiscussionDto.fromMap(discussionMap));

  List<PerformanceRatingDto> buildPerformanceRatingsFromLineupAndEvents() {
    var performanceRatings = <PerformanceRatingDto>[];

    var lineup = lineups?.firstWhere((lineup) => lineup.teamId == teamId);
    if (lineup != null) {
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
    }

    var events = this.events?.firstWhere((events) => events.teamId == teamId);
    events?.events?.forEach((event) {
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
