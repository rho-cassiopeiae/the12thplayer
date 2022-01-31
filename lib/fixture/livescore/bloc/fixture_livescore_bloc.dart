import 'dart:async';

import '../services/fixture_livescore_service.dart';
import '../../../general/bloc/bloc.dart';
import 'fixture_livescore_actions.dart';
import 'fixture_livescore_states.dart';

class FixtureLivescoreBloc extends Bloc<FixtureLivescoreAction> {
  final FixtureLivescoreService _fixtureLivescoreService;

  StreamController<LoadFixtureState> _fixtureLivescoreStateChannel =
      StreamController<LoadFixtureState>.broadcast();
  Stream<LoadFixtureState> get fixtureLivescoreState$ =>
      _fixtureLivescoreStateChannel.stream;

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
      }
    });
  }

  @override
  void dispose({FixtureLivescoreAction cleanupAction}) {
    _fixtureLivescoreStateChannel.close();
    _fixtureLivescoreStateChannel = null;

    if (cleanupAction != null) {
      dispatchAction(cleanupAction);
    } else {
      actionChannel.close();
      actionChannel = null;
    }
  }

  void _loadFixture(LoadFixture action) async {
    var result = await _fixtureLivescoreService.loadFixture(action.fixtureId);

    var state = FixtureReady(
      fixture: result.item1,
      shouldSubscribe: result.item2,
    );

    action.complete(state);
    _fixtureLivescoreStateChannel?.add(state);
  }

  void _subscribeToFixture(SubscribeToFixture action) async {
    await for (var fixture in _fixtureLivescoreService.subscribeToFixture(
      action.fixtureId,
    )) {
      _fixtureLivescoreStateChannel?.add(FixtureReady(fixture: fixture));
    }
  }

  void _unsubscribeFromFixture(UnsubscribeFromFixture action) {
    _fixtureLivescoreService.unsubscribeFromFixture(action.fixtureId);
  }
}
