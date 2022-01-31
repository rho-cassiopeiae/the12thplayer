import 'dart:async';

import 'player_rating_actions.dart';
import 'player_rating_states.dart';
import '../services/player_rating_service.dart';
import '../../../../general/bloc/bloc.dart';

class PlayerRatingBloc extends Bloc<PlayerRatingAction> {
  final PlayerRatingService _playerRatingService;

  StreamController<LoadPlayerRatingsState> _playerRatingsStateChannel =
      StreamController<LoadPlayerRatingsState>.broadcast();
  Stream<LoadPlayerRatingsState> get playerRatingsState$ =>
      _playerRatingsStateChannel.stream;

  PlayerRatingBloc(this._playerRatingService) {
    actionChannel.stream.listen((action) {
      if (action is LoadPlayerRatings) {
        _loadPlayerRatings(action);
      } else if (action is RatePlayer) {
        _ratePlayer(action);
      }
    });
  }

  @override
  void dispose({PlayerRatingAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _playerRatingsStateChannel.close();
    _playerRatingsStateChannel = null;
  }

  void _loadPlayerRatings(LoadPlayerRatings action) async {
    var result = await _playerRatingService.loadPlayerRatings(action.fixtureId);

    var state = result.fold(
      (error) => PlayerRatingsError(),
      (playerRatings) => PlayerRatingsReady(playerRatings: playerRatings),
    );

    _playerRatingsStateChannel?.add(state);
  }

  void _ratePlayer(RatePlayer action) async {
    var playerRatings = await _playerRatingService.ratePlayer(
      action.fixtureId,
      action.participantKey,
      action.rating,
    );

    _playerRatingsStateChannel?.add(
      PlayerRatingsReady(playerRatings: playerRatings),
    );
  }
}
