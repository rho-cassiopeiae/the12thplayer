import 'dart:async';

import 'package:flutter/foundation.dart';

import 'image_states.dart';

abstract class ImageAction {}

abstract class ImageActionFutureState<TState extends ImageState>
    extends ImageAction {
  final Completer<TState> _stateReady = Completer<TState>();
  Future<TState> get state => _stateReady.future;

  void complete(TState state) => _stateReady.complete(state);
}

class GetProfileImage extends ImageActionFutureState<ImageState> {
  final String username;

  GetProfileImage({@required this.username});
}
