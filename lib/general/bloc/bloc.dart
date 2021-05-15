import 'dart:async';

abstract class Bloc<TAction> {
  StreamController<TAction> actionChannel = StreamController<TAction>();

  void dispatchAction(TAction action) {
    actionChannel.add(action);
  }

  void dispose({TAction cleanupAction});
}
