import '../dto/game_time_dto.dart';

class GameTimeEntity {
  final int minute;
  final int extraTimeMinute;
  final int addedTimeMinute;

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['minute'] = minute;
    map['extraTimeMinute'] = extraTimeMinute;
    map['addedTimeMinute'] = addedTimeMinute;

    return map;
  }

  GameTimeEntity.fromMap(Map<String, dynamic> map)
      : minute = map['minute'],
        extraTimeMinute = map['extraTimeMinute'],
        addedTimeMinute = map['addedTimeMinute'];

  GameTimeEntity.fromDto(GameTimeDto gameTime)
      : minute = gameTime.minute,
        extraTimeMinute = gameTime.extraTimeMinute,
        addedTimeMinute = gameTime.addedTimeMinute;
}
