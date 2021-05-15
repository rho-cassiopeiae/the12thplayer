import 'game_time_dto.dart';
import 'score_dto.dart';
import 'season_dto.dart';
import 'team_dto.dart';
import 'venue_dto.dart';

class FixtureSummaryDto {
  final int id;
  final bool homeStatus;
  final int startTime;
  final String status;
  final GameTimeDto gameTime;
  final ScoreDto score;
  final SeasonDto season;
  final TeamDto opponentTeam;
  final VenueDto venue;

  FixtureSummaryDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        homeStatus = map['homeStatus'],
        startTime = map['startTime'],
        status = map['status'],
        gameTime = GameTimeDto.fromMap(map['gameTime']),
        score = ScoreDto.fromMap(map['score']),
        season = SeasonDto.fromMap(map['season']),
        opponentTeam = TeamDto.fromMap(map['opponentTeam']),
        venue = VenueDto.fromMap(map['venue']);
}
