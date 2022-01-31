class GameTimeDto {
  final int minute;
  final int extraTimeMinute;
  final int addedTimeMinute;

  GameTimeDto.fromMap(Map<String, dynamic> map)
      : minute = map['minute'],
        extraTimeMinute = map['extraTimeMinute'],
        addedTimeMinute = map['addedTimeMinute'];
}
