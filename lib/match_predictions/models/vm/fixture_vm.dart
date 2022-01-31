import '../dto/fixture_dto.dart';
import 'game_time_vm.dart';
import 'score_vm.dart';

class FixtureVm {
  final int id;
  final DateTime startTime;
  final String status;
  final GameTimeVm gameTime;
  final ScoreVm score;
  final String homeTeamName;
  final String homeTeamLogoUrl;
  final String guestTeamName;
  final String guestTeamLogoUrl;
  final String predictedScore;

  FixtureVm._(
    this.id,
    this.startTime,
    this.status,
    this.gameTime,
    this.score,
    this.homeTeamName,
    this.homeTeamLogoUrl,
    this.guestTeamName,
    this.guestTeamLogoUrl,
    this.predictedScore,
  );

  FixtureVm.fromDto(FixtureDto fixture)
      : id = fixture.id,
        startTime = DateTime.fromMillisecondsSinceEpoch(fixture.startTime),
        status = fixture.status.replaceAll('_', ' '),
        gameTime = GameTimeVm.fromDto(fixture.gameTime),
        score = ScoreVm.fromDto(fixture.score),
        homeTeamName = fixture.homeTeamName,
        homeTeamLogoUrl = fixture.homeTeamLogoUrl,
        guestTeamName = fixture.guestTeamName,
        guestTeamLogoUrl = fixture.guestTeamLogoUrl,
        predictedScore = fixture.predictedHomeTeamScore != null &&
                fixture.predictedGuestTeamScore != null
            ? '${fixture.predictedHomeTeamScore}${fixture.predictedGuestTeamScore}'
            : null;

  FixtureVm copyWith({
    DateTime startTime,
    String status,
    GameTimeVm gameTime,
    ScoreVm score,
    String predictedScore,
  }) =>
      FixtureVm._(
        id,
        startTime ?? this.startTime,
        status ?? this.status,
        gameTime ?? this.gameTime,
        score ?? this.score,
        homeTeamName,
        homeTeamLogoUrl,
        guestTeamName,
        guestTeamLogoUrl,
        predictedScore ?? this.predictedScore,
      );

  bool get started => (gameTime.minute ?? 0) > 0;

  String get scoreString => isUpcoming ? '-:-' : score.toString();

  bool get isUpcoming =>
      status == 'NS' ||
      status == 'CANCL' ||
      status == 'POSTP' ||
      status == 'DELAYED' ||
      status == 'TBA';

  bool get isPostponed => status == 'POSTP';

  bool get isLiveInPlay => status == 'LIVE' || status == 'ET';

  bool get isLivePenShootout => status == 'PEN LIVE';

  bool get isLiveOnBreak => status == 'HT' || status == 'BREAK';

  bool get isLive => isLiveInPlay || isLivePenShootout || isLiveOnBreak;

  bool get isPaused => status == 'INT' || status == 'ABAN' || status == 'SUSP';

  bool get isCompleted =>
      status == 'FT' || status == 'AET' || status == 'FT PEN';
}
