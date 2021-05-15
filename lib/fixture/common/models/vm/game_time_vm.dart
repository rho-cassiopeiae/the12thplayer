import '../entities/game_time_entity.dart';

class GameTimeVm {
  final int minute;
  final int extraTimeMinute;
  final int addedTimeMinute;

  GameTimeVm.fromEntity(GameTimeEntity gameTime)
      : minute = gameTime.minute,
        extraTimeMinute = gameTime.extraTimeMinute,
        addedTimeMinute = gameTime.addedTimeMinute;

  @override
  String toString() {
    var minute = this.minute;
    if (minute == null) {
      return '';
    }
    if (minute > 90) {
      minute = 90;
    }
    if (extraTimeMinute != null) {
      minute += extraTimeMinute;
    }
    var addedTimeMinute =
        this.addedTimeMinute != null ? '+${this.addedTimeMinute}' : '';

    return '$minute$addedTimeMinute\'';
  }
}
