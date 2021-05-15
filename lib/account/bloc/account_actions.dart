import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'account_states.dart';

abstract class AccountAction {}

abstract class AccountActionFutureState<TState extends AccountState>
    extends AccountAction {
  final Completer<TState> _stateReady = Completer<TState>();
  Future<TState> get state => _stateReady.future;

  void complete(TState state) => _stateReady.complete(state);
}

class LoadAccount extends AccountActionFutureState<AccountState> {}

class SignUp extends AccountActionFutureState<AuthState> {
  final String email;
  final String username;
  final String password;

  SignUp({
    @required this.email,
    @required this.username,
    @required this.password,
  });
}

class ConfirmEmail extends AccountActionFutureState<AuthState> {
  final String confirmationCode;

  ConfirmEmail({@required this.confirmationCode});
}

class SignIn extends AccountActionFutureState<AuthState> {
  final String email;
  final String password;

  SignIn({
    @required this.email,
    @required this.password,
  });
}

class UpdateProfileImage
    extends AccountActionFutureState<UpdateProfileImageState> {
  final File imageFile;

  UpdateProfileImage({@required this.imageFile});
}
