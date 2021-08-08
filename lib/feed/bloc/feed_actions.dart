import 'dart:async';

import 'package:flutter/foundation.dart';

import 'feed_states.dart';

abstract class FeedAction {}

abstract class FeedActionFutureState<TState extends FeedState>
    extends FeedAction {
  final Completer<TState> _stateReady = Completer<TState>();
  Future<TState> get state => _stateReady.future;

  void complete(TState state) => _stateReady.complete(state);
}

class SubscribeToFeed extends FeedAction {}

class ProcessVideoUrl extends FeedActionFutureState<ProcessVideoUrlState> {
  final String url;

  ProcessVideoUrl({@required this.url});
}

class CreateNewArticle extends FeedAction {
  final String content;

  CreateNewArticle({@required this.content});
}
