import 'dart:async';

mixin AwaitableState<T> {
  final Completer<T> _stateReady = Completer<T>();

  Future<T> get state => _stateReady.future;

  void complete(T state) => _stateReady.complete(state);
}
