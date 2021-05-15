class SeasonDto {
  final String leagueName;
  final String leagueLogoUrl;

  SeasonDto.fromMap(Map<String, dynamic> map)
      : leagueName = map['leagueName'],
        leagueLogoUrl = map['leagueLogoUrl'];
}
