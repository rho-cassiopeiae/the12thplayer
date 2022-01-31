import 'package:flutter/foundation.dart';

import '../models/vm/account_vm.dart';

abstract class AccountState {}

abstract class LoadAccountState extends AccountState {}

class AccountLoading extends LoadAccountState {}

class AccountReady extends LoadAccountState {
  final AccountVm account;

  AccountReady({@required this.account});
}

class AccountError extends LoadAccountState {}

abstract class AuthenticateState extends AccountState {}

class AuthenticationSucceeded extends AuthenticateState {}

class AuthenticationFailed extends AuthenticateState {}
