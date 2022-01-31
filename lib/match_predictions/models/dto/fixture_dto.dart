import 'game_time_dto.dart';
import 'score_dto.dart';
import '../../../general/extensions/map_extension.dart';

class FixtureDto {
  final int id;
  final int startTime;
  final String status;
  final GameTimeDto gameTime;
  final ScoreDto score;
  final String homeTeamName;
  final String homeTeamLogoUrl;
  final String guestTeamName;
  final String guestTeamLogoUrl;
  final int predictedHomeTeamScore;
  final int predictedGuestTeamScore;

  FixtureDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        startTime = map['startTime'],
        status = map['status'],
        gameTime = GameTimeDto.fromMap(map['gameTime']),
        score = ScoreDto.fromMap(map['score']),
        homeTeamName = map['homeTeamName'],
        homeTeamLogoUrl = map['homeTeamLogoUrl'],
        guestTeamName = map['guestTeamName'],
        guestTeamLogoUrl = map['guestTeamLogoUrl'],
        predictedHomeTeamScore = map.getOrNull('predictedHomeTeamScore'),
        predictedGuestTeamScore = map.getOrNull('predictedGuestTeamScore');
}
