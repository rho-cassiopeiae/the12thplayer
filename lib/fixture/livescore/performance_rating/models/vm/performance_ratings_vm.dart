import '../entities/fixture_performance_ratings_entity.dart';
import '../../../../common/models/entities/fixture_entity.dart';
import '../entities/performance_rating_entity.dart';

class PerformanceRatingsVm {
  final bool isFinalized;
  List<PerformanceRatingVm> _ratings;
  List<PerformanceRatingVm> get ratings => _ratings;

  PerformanceRatingsVm.fromEntity(
    FixtureEntity fixture,
    FixturePerformanceRatingsEntity fixturePerformanceRatings,
  ) : isFinalized = fixturePerformanceRatings.isFinalized {
    _ratings = [];

    var performanceRatings = fixturePerformanceRatings.performanceRatings;
    if (performanceRatings != null) {
      var players = fixture.allPlayers;
      for (var performanceRating in performanceRatings) {
        if (performanceRating.participantIdentifier.startsWith('manager')) {
          var manager = fixture.lineups
              .firstWhere((lineup) => lineup.teamId == fixture.teamId)
              .manager;

          if (manager != null) {
            _ratings.add(
              PerformanceRatingVm.fromEntity(
                performanceRating,
                manager.name,
                manager.imageUrl,
                'MG',
              ),
            );
          }
        } else {
          var playerId = int.parse(
            performanceRating.participantIdentifier.split(':')[1],
          );
          var player = players.firstWhere(
            (player) => player.id == playerId,
            orElse: () => null,
          );
          if (player != null) {
            _ratings.add(
              PerformanceRatingVm.fromEntity(
                performanceRating,
                player.name,
                player.imageUrl,
                player.position,
              ),
            );
          }
        }
      }
    }

    // @@TODO: Sort that starting xi players go first, then subs, then manager.
    _ratings.sort((r1, r2) => _positionToPriority[r1.participantPosition]
        .compareTo(_positionToPriority[r2.participantPosition]));
  }
}

class PerformanceRatingVm {
  final String participantIdentifier;
  final String participantName;
  final String participantImageUrl;
  final String participantPosition;
  final double myRating;
  final int totalRating;
  final int totalVoters;

  String get avgRating => totalRating == null || totalVoters == null
      ? '**'
      : totalVoters == 0
          ? '0.00'
          : (totalRating / totalVoters).toStringAsFixed(2);

  String get totalVotersString => totalRating == null || totalVoters == null
      ? '(** votes)'
      : '($totalVoters vote' + (totalVoters != 1 ? 's)' : ')');

  PerformanceRatingVm.fromEntity(
    PerformanceRatingEntity performanceRating,
    String participantName,
    String participantImageUrl,
    String participantPosition,
  )   : participantIdentifier = performanceRating.participantIdentifier,
        participantName = participantName,
        participantImageUrl = participantImageUrl ??
            'https://cdn.sportmonks.com/images/soccer/placeholder.png', // @@TODO: Another way to specify dummy image.
        participantPosition = participantPosition,
        myRating = performanceRating.myRating,
        totalRating = performanceRating.totalRating,
        totalVoters = performanceRating.totalVoters;
}

var _positionToPriority = {
  'G': 1,
  'D': 2,
  'M': 3,
  'A': 4,
  null: 5,
  'MG': 6,
};
