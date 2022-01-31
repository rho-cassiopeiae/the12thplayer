import 'package:flutter/foundation.dart';

import '../../../general/bloc/mixins.dart';
import 'fixture_livescore_states.dart';

abstract class FixtureLivescoreAction {}

abstract class FixtureLivescoreActionAwaitable<T extends FixtureLivescoreState>
    extends FixtureLivescoreAction with AwaitableState<T> {}

class LoadFixture extends FixtureLivescoreActionAwaitable<LoadFixtureState> {
  final int fixtureId;

  LoadFixture({@required this.fixtureId});
}

class SubscribeToFixture extends FixtureLivescoreAction {
  final int fixtureId;

  SubscribeToFixture({@required this.fixtureId});
}

class UnsubscribeFromFixture extends FixtureLivescoreAction {
  final int fixtureId;

  UnsubscribeFromFixture({@required this.fixtureId});
}
