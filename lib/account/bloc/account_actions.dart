import 'dart:io';

import 'package:flutter/foundation.dart';

import 'account_states.dart';
import '../../general/bloc/mixins.dart';

abstract class AccountAction {}

abstract class AccountActionAwaitable<T extends AccountState>
    extends AccountAction with AwaitableState<T> {}

class LoadAccount extends AccountActionAwaitable<LoadAccountState> {}

class SignUp extends AccountActionAwaitable<AuthenticateState> {
  final String email;
  final String username;
  final String password;

  SignUp({
    @required this.email,
    @required this.username,
    @required this.password,
  });
}

class ConfirmEmail extends AccountActionAwaitable<AuthenticateState> {
  final String email;
  final String confirmationCode;

  ConfirmEmail({
    @required this.email,
    @required this.confirmationCode,
  });
}

class SignIn extends AccountActionAwaitable<AuthenticateState> {
  final String email;
  final String password;

  SignIn({
    @required this.email,
    @required this.password,
  });
}

class UpdateProfileImage
    extends AccountActionAwaitable<ProfileImageUpdateCompleted> {
  final File imageFile;

  UpdateProfileImage({@required this.imageFile});
}
