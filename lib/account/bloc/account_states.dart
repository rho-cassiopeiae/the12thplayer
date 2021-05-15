import 'package:flutter/foundation.dart';

import '../models/vm/account_vm.dart';

abstract class AccountState {}

class AccountLoading extends AccountState {}

class AccountReady extends AccountState {
  final AccountVm account;

  AccountReady({@required this.account});
}

class AccountError extends AccountState {}

abstract class AuthState extends AccountState {}

class AuthSuccess extends AuthState {
  final AccountVm account;

  AuthSuccess({@required this.account});
}

class AuthError extends AuthState {
  final String message;

  AuthError({@required this.message});
}

abstract class UpdateProfileImageState extends AccountState {}

class UpdateProfileImageReady extends UpdateProfileImageState {}

class UpdateProfileImageError extends UpdateProfileImageState {
  final String message;

  UpdateProfileImageError({@required this.message});
}
