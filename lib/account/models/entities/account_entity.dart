import 'package:flutter/foundation.dart';

import '../../persistence/tables/account_table.dart';
import '../../enums/account_type.dart';

class AccountEntity {
  final String email;
  final String username;
  final String accessToken;
  final String refreshToken;
  final AccountType type;

  AccountEntity.fromMap(Map<String, dynamic> map)
      : email = map[AccountTable.email],
        username = map[AccountTable.username],
        accessToken = map[AccountTable.accessToken],
        refreshToken = map[AccountTable.refreshToken],
        type = AccountType.values[map[AccountTable.type]];

  AccountEntity.guest()
      : email = null,
        username = null,
        accessToken = null,
        refreshToken = null,
        type = AccountType.GuestAccount;

  AccountEntity.unconfirmed({
    @required String email,
    @required String username,
  })  : email = email,
        username = username,
        accessToken = null,
        refreshToken = null,
        type = AccountType.UnconfirmedAccount;

  AccountEntity.confirmed({
    @required String email,
    @required String username,
    @required String accessToken,
    @required String refreshToken,
  })  : email = email,
        username = username,
        accessToken = accessToken,
        refreshToken = refreshToken,
        type = AccountType.ConfirmedAccount;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[AccountTable.email] = email;
    map[AccountTable.username] = username;
    map[AccountTable.accessToken] = accessToken;
    map[AccountTable.refreshToken] = refreshToken;
    map[AccountTable.type] = type.index;

    return map;
  }
}
