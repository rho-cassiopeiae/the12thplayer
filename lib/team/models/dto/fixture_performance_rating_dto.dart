class FixturePerformanceRatingDto {
  final String participantIdentifier;
  final int totalRating;
  final int totalVoters;
  final String opponentTeamName;
  final String opponentTeamLogoUrl;
  final int startTime;
  final bool homeStatus;
  final int localTeamScore;
  final int visitorTeamScore;

  FixturePerformanceRatingDto.fromMap(Map<String, dynamic> map)
      : participantIdentifier = map['participantIdentifier'],
        totalRating = map['totalRating'],
        totalVoters = map['totalVoters'],
        opponentTeamName = map['opponentTeamName'],
        opponentTeamLogoUrl = map['opponentTeamLogoUrl'],
        startTime = map['startTime'],
        homeStatus = map['homeStatus'],
        localTeamScore = map['localTeamScore'],
        visitorTeamScore = map['visitorTeamScore'];
}
