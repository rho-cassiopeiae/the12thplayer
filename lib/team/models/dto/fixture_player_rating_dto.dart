class FixturePlayerRatingDto {
  final String opponentTeamName;
  final String opponentTeamLogoUrl;
  final int fixtureStartTime;
  final bool fixtureHomeStatus;
  final int homeTeamScore;
  final int guestTeamScore;
  final int totalRating;
  final int totalVoters;

  FixturePlayerRatingDto.fromMap(Map<String, dynamic> map)
      : opponentTeamName = map['opponentTeamName'],
        opponentTeamLogoUrl = map['opponentTeamLogoUrl'],
        fixtureStartTime = map['fixtureStartTime'],
        fixtureHomeStatus = map['fixtureHomeStatus'],
        homeTeamScore = map['homeTeamScore'],
        guestTeamScore = map['guestTeamScore'],
        totalRating = map['totalRating'],
        totalVoters = map['totalVoters'];
}
