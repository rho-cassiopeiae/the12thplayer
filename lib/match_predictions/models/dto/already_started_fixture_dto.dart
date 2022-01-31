import 'game_time_dto.dart';
import 'score_dto.dart';

class AlreadyStartedFixtureDto {
  final int id;
  final int startTime;
  final String status;
  final GameTimeDto gameTime;
  final ScoreDto score;

  AlreadyStartedFixtureDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        startTime = map['startTime'],
        status = map['status'],
        gameTime = GameTimeDto.fromMap(map['gameTime']),
        score = ScoreDto.fromMap(map['score']);
}
