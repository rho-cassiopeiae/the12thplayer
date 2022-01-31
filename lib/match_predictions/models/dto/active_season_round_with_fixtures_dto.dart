import 'fixture_dto.dart';

class ActiveSeasonRoundWithFixturesDto {
  final int seasonId;
  final String leagueName;
  final String leagueLogoUrl;
  final int roundId;
  final String roundName;
  final Iterable<FixtureDto> fixtures;

  ActiveSeasonRoundWithFixturesDto.fromMap(Map<String, dynamic> map)
      : seasonId = map['seasonId'],
        leagueName = map['leagueName'],
        leagueLogoUrl = map['leagueLogoUrl'],
        roundId = map['roundId'],
        roundName = map['roundName'],
        fixtures = (map['fixtures'] as List)
            .map((fixtureMap) => FixtureDto.fromMap(fixtureMap));
}
