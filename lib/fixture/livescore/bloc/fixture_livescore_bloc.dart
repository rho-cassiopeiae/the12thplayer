import 'dart:async';

import '../services/fixture_livescore_service.dart';
import '../../../general/bloc/bloc.dart';
import 'fixture_livescore_actions.dart';
import 'fixture_livescore_states.dart';

class FixtureLivescoreBloc extends Bloc<FixtureLivescoreAction> {
  final FixtureLivescoreService _fixtureLivescoreService;

  StreamController<FixtureLivescoreState> _stateChannel =
      StreamController<FixtureLivescoreState>.broadcast();
  Stream<FixtureLivescoreState> get state$ => _stateChannel.stream;

  FixtureLivescoreState _latestReadyState;
  FixtureLivescoreState get latestReadyState => _latestReadyState;

  FixtureLivescoreBloc(this._fixtureLivescoreService) {
    actionChannel.stream.listen((action) {
      if (action is LoadFixture) {
        _loadFixture(action);
      } else if (action is SubscribeToFixture) {
        _subscribeToFixture(action);
      } else if (action is UnsubscribeFromFixture) {
        _unsubscribeFromFixture(action);
        actionChannel.close();
        actionChannel = null;
      } else if (action is RateParticipantOfGivenFixture) {
        _rateParticipantOfGivenFixture(action);
      }
    });
  }

  @override
  void dispose({FixtureLivescoreAction cleanupAction}) {
    _stateChannel.close();
    _stateChannel = null;
    _latestReadyState = null;

    if (cleanupAction != null) {
      dispatchAction(cleanupAction);
    } else {
      actionChannel.close();
      actionChannel = null;
    }
  }

  void replayLatestReadyState() {
    _stateChannel?.add(latestReadyState);
  }

  void _loadFixture(LoadFixture action) async {
    var result = await _fixtureLivescoreService.loadFixture(
      action.fixtureId,
    );
    var state = result.fold(
      (error) => FixtureError(message: error.toString()),
      (fixture) => FixtureReady(fixture: fixture),
    );

    action.complete(state);
    _stateChannel?.add(state);

    if (state is FixtureReady) {
      _latestReadyState = state;
    }
  }

  void _subscribeToFixture(SubscribeToFixture action) async {
    await for (var update in _fixtureLivescoreService.subscribeToFixture(
      action.fixtureId,
    )) {
      var state = update.fold(
        (error) => FixtureError(message: error.toString()),
        (fixture) => FixtureReady(fixture: fixture),
      );

      _stateChannel?.add(state);

      if (state is FixtureReady) {
        _latestReadyState = state;
      }
    }
  }

  void _unsubscribeFromFixture(UnsubscribeFromFixture action) {
    _fixtureLivescoreService.unsubscribeFromFixture(action.fixtureId);
  }

  void _rateParticipantOfGivenFixture(
    RateParticipantOfGivenFixture action,
  ) async {
    var result = await _fixtureLivescoreService.rateParticipantOfGivenFixture(
      action.fixtureId,
      action.participantIdentifier,
      action.rating,
    );

    var state = result.fold(
      (error) => FixtureError(message: error.toString()),
      (fixture) => FixtureReady(fixture: fixture),
    );

    _stateChannel?.add(state);

    if (state is FixtureReady) {
      _latestReadyState = state;
    }
  }
}
