import '../../../common/models/dto/fixture_summary_dto.dart';
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
        super.fromMap(map);

  bool get isCompleted =>
      status == 'FT' || status == 'AET' || status == 'FT_PEN';
}
