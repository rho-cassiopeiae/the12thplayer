import '../../../../general/extensions/map_extension.dart';
import '../../../common/models/dto/game_time_dto.dart';
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
  final String refereeName;
  final Iterable<TeamColorDto> colors;
  final Iterable<TeamLineupDto> lineups;
  final Iterable<TeamMatchEventsDto> events;
  final Iterable<TeamStatsDto> stats;

  FixtureLivescoreUpdateDto.fromMap(Map<String, dynamic> map)
      : fixtureId = map['fixtureId'],
        teamId = map['teamId'],
        startTime = map.getOrNull('startTime'),
        status = map['status'],
        gameTime = map.containsKey('gameTime')
            ? GameTimeDto.fromMap(map['gameTime'])
            : null,
        score =
            map.containsKey('score') ? ScoreDto.fromMap(map['score']) : null,
        refereeName = map.getOrNull('refereeName'),
        colors = map.containsKey('colors')
            ? (map['colors'] as List)
                .map((colorMap) => TeamColorDto.fromMap(colorMap))
            : null,
        lineups = map.containsKey('lineups')
            ? (map['lineups'] as List)
                .map((lineupMap) => TeamLineupDto.fromMap(lineupMap))
            : null,
        events = map.containsKey('events')
            ? (map['events'] as List)
                .map((eventsMap) => TeamMatchEventsDto.fromMap(eventsMap))
            : null,
        stats = map.containsKey('stats')
            ? (map['stats'] as List)
                .map((statsMap) => TeamStatsDto.fromMap(statsMap))
            : null;
}
