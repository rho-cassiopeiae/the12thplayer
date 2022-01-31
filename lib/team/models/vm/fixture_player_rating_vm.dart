import '../dto/fixture_player_rating_dto.dart';

class FixturePlayerRatingVm {
  final String opponentTeamName;
  final String opponentTeamLogoUrl;
  final DateTime fixtureStartTime;
  final bool fixtureHomeStatus;
  final int homeTeamScore;
  final int guestTeamScore;
  final int totalRating;
  final int totalVoters;

  double get avgRating => totalVoters > 0
      ? (totalRating / totalVoters * 10).roundToDouble() / 10
      : null;

  FixturePlayerRatingVm.fromDto(FixturePlayerRatingDto rating)
      : opponentTeamName = rating.opponentTeamName,
        opponentTeamLogoUrl = rating.opponentTeamLogoUrl,
        fixtureStartTime =
            DateTime.fromMillisecondsSinceEpoch(rating.fixtureStartTime),
        fixtureHomeStatus = rating.fixtureHomeStatus,
        homeTeamScore = rating.homeTeamScore,
        guestTeamScore = rating.guestTeamScore,
        totalRating = rating.totalRating,
        totalVoters = rating.totalVoters;
}
