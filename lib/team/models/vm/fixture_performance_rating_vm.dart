import '../dto/fixture_performance_rating_dto.dart';

class FixturePerformanceRatingVm {
  final String participantIdentifier;
  final int totalRating;
  final int totalVoters;
  final String opponentTeamName;
  final String opponentTeamLogoUrl;
  final DateTime startTime;
  final bool homeStatus;
  final int localTeamScore;
  final int visitorTeamScore;

  double get avgRating => totalVoters > 0
      ? (totalRating / totalVoters * 10).roundToDouble() / 10
      : null;

  FixturePerformanceRatingVm.fromDto(FixturePerformanceRatingDto rating)
      : participantIdentifier = rating.participantIdentifier,
        totalRating = rating.totalRating,
        totalVoters = rating.totalVoters,
        opponentTeamName = rating.opponentTeamName,
        opponentTeamLogoUrl = rating.opponentTeamLogoUrl,
        startTime = DateTime.fromMillisecondsSinceEpoch(rating.startTime),
        homeStatus = rating.homeStatus,
        localTeamScore = rating.localTeamScore,
        visitorTeamScore = rating.visitorTeamScore;
}
