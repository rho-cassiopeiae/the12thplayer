import '../entities/fixture_player_ratings_entity.dart';
import '../../../../common/models/entities/fixture_entity.dart';
import '../entities/player_rating_entity.dart';

class PlayerRatingsVm {
  final bool finalized;
  List<PlayerRatingVm> _ratings;
  List<PlayerRatingVm> get ratings => _ratings;

  PlayerRatingsVm.fromEntity(
    FixtureEntity fixture,
    FixturePlayerRatingsEntity fixturePlayerRatings,
  ) : finalized = fixturePlayerRatings.finalized {
    _ratings = [];

    var players = fixture.allPlayers;
    for (var playerRating in fixturePlayerRatings.playerRatings) {
      if (playerRating.participantKey.startsWith('m')) {
        var manager = fixture.lineups
            ?.firstWhere((lineup) => lineup.teamId == fixture.teamId)
            ?.manager;

        if (manager != null) {
          _ratings.add(
            PlayerRatingVm.fromEntity(
              playerRating: playerRating,
              displayName: manager.name,
              imageUrl: manager.imageUrl,
              position: 'Mg',
            ),
          );
        }
      } else {
        var participantKeySplit = playerRating.participantKey.split(':');
        var playerId = int.parse(participantKeySplit[1]);
        var player = players.firstWhere(
          (player) => player.id == playerId,
          orElse: () => null,
        );
        if (player != null) {
          _ratings.add(
            PlayerRatingVm.fromEntity(
              playerRating: playerRating,
              displayName: player.getDisplayName(),
              imageUrl: player.imageUrl,
              position: participantKeySplit[0] != 's' ? player.position : 'S',
            ),
          );
        }
      }
    }

    _ratings.sort((r1, r2) => _positionToPriority[r1.position]
        .compareTo(_positionToPriority[r2.position]));
  }
}

class PlayerRatingVm {
  final String participantKey;
  final String displayName;
  final String imageUrl;
  final String position;
  final double userRating;
  final int _totalRating;
  final int _totalVoters;

  String get avgRating => _totalRating == null || _totalVoters == null
      ? '**'
      : _totalVoters == 0
          ? '0.00'
          : (_totalRating / _totalVoters).toStringAsFixed(2);

  String get totalVoters => _totalRating == null || _totalVoters == null
      ? '(** votes)'
      : '($_totalVoters vote' + (_totalVoters != 1 ? 's)' : ')');

  PlayerRatingVm.fromEntity({
    PlayerRatingEntity playerRating,
    String displayName,
    String imageUrl,
    String position,
  })  : participantKey = playerRating.participantKey,
        displayName = displayName,
        imageUrl = imageUrl ??
            'https://cdn.sportmonks.com/images/soccer/placeholder.png', // @@TODO: Another way to specify dummy image.
        position = position,
        userRating = playerRating.userRating,
        _totalRating = playerRating.totalRating,
        _totalVoters = playerRating.totalVoters;
}

var _positionToPriority = {
  'G': 1,
  'D': 2,
  'M': 3,
  'A': 4,
  'S': 5,
  'Mg': 6,
};
