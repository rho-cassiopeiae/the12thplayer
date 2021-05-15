import 'dart:async';

import 'package:flutter/foundation.dart';

import 'fixture_livescore_states.dart';

abstract class FixtureLivescoreAction {}

abstract class FixtureLivescoreActionFutureState<
    TState extends FixtureLivescoreState> extends FixtureLivescoreAction {
  final Completer<TState> _stateReady = Completer<TState>();
  Future<TState> get state => _stateReady.future;

  void complete(TState state) => _stateReady.complete(state);
}

class LoadFixture
    extends FixtureLivescoreActionFutureState<FixtureLivescoreState> {
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

class RateParticipantOfGivenFixture extends FixtureLivescoreAction {
  final int fixtureId;
  final String participantIdentifier;
  final double rating;

  RateParticipantOfGivenFixture({
    @required this.fixtureId,
    @required this.participantIdentifier,
    @required this.rating,
  });
}
