import 'game_time_vm.dart';
import '../entities/fixture_entity.dart';
import '../../../../general/models/entities/team_entity.dart';
import 'league_vm.dart';
import 'score_vm.dart';
import 'team_vm.dart';
import 'venue_vm.dart';

class FixtureSummaryVm {
  final int id;
  final int teamId;
  final DateTime startTime;
  final String status;
  final GameTimeVm gameTime;
  final ScoreVm score;
  final LeagueVm league;
  final TeamVm homeTeam;
  final TeamVm awayTeam;
  final VenueVm venue;

  String get minuteString => gameTime.toString();
  String get scoreString => isUpcoming ? '-:-' : score.toString();

  FixtureSummaryVm.fromEntity(TeamEntity team, FixtureEntity fixture)
      : id = fixture.id,
        teamId = team.id,
        startTime = fixture.startTime == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(fixture.startTime),
        status = fixture.status,
        gameTime = GameTimeVm.fromEntity(fixture.gameTime),
        score = ScoreVm.fromEntity(fixture.score),
        league = LeagueVm(
          name: fixture.leagueName,
          logoUrl: fixture.leagueLogoUrl,
        ),
        homeTeam = fixture.homeStatus
            ? TeamVm(
                id: team.id,
                name: team.name,
                logoUrl: team.logoUrl,
              )
            : TeamVm(
                id: fixture.opponentTeamId,
                name: fixture.opponentTeamName,
                logoUrl: fixture.opponentTeamLogoUrl,
              ),
        awayTeam = fixture.homeStatus
            ? TeamVm(
                id: fixture.opponentTeamId,
                name: fixture.opponentTeamName,
                logoUrl: fixture.opponentTeamLogoUrl,
              )
            : TeamVm(
                id: team.id,
                name: team.name,
                logoUrl: team.logoUrl,
              ),
        venue = VenueVm(
          name: fixture.venueName,
          imageUrl: fixture.venueImageUrl,
        );

  bool get isUpcoming =>
      status == 'NS' ||
      status == 'CANCL' ||
      status == 'POSTP' ||
      status == 'DELAYED' ||
      status == 'TBA';

  bool get isPostponed => status == 'POSTP';

  bool get isLiveInPlay => status == 'LIVE' || status == 'ET';

  bool get isLivePenShootout => status == 'PEN_LIVE';

  bool get isLiveOnBreak => status == 'HT' || status == 'BREAK';

  bool get isLive => isLiveInPlay || isLivePenShootout || isLiveOnBreak;

  bool get isPaused => status == 'INT' || status == 'ABAN' || status == 'SUSP';

  bool get isCompleted =>
      status == 'FT' || status == 'AET' || status == 'FT_PEN';

  String get completedStatus => status == 'FT_PEN' ? 'FT PEN' : status;
}
