import '../dto/active_season_round_with_fixtures_dto.dart';
import 'fixture_vm.dart';

class ActiveSeasonRoundWithFixturesVm {
  final int seasonId;
  final String leagueName;
  final String leagueLogoUrl;
  final int roundId;
  final String roundName;
  final List<FixtureVm> fixtures;

  ActiveSeasonRoundWithFixturesVm._(
    this.seasonId,
    this.leagueName,
    this.leagueLogoUrl,
    this.roundId,
    this.roundName,
    this.fixtures,
  );

  ActiveSeasonRoundWithFixturesVm.fromDto(
    ActiveSeasonRoundWithFixturesDto seasonRound,
  )   : seasonId = seasonRound.seasonId,
        leagueName = seasonRound.leagueName,
        leagueLogoUrl = seasonRound.leagueLogoUrl,
        roundId = seasonRound.roundId,
        roundName = 'Matchday ${seasonRound.roundName}',
        fixtures = seasonRound.fixtures
            .map((fixture) => FixtureVm.fromDto(fixture))
            .toList();

  ActiveSeasonRoundWithFixturesVm copy() => ActiveSeasonRoundWithFixturesVm._(
        seasonId,
        leagueName,
        leagueLogoUrl,
        roundId,
        roundName,
        fixtures.toList(),
      );
}
