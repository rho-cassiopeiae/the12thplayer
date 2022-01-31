import 'package:flutter/foundation.dart';
import 'package:ulid/ulid.dart';

import '../../persistence/tables/account_table.dart';
import '../../enums/account_type.dart';

class AccountEntity {
  final String deviceId;
  final String email;
  final String username;
  final String accessToken;
  final String refreshToken;
  final AccountType type;

  AccountEntity.fromMap(Map<String, dynamic> map)
      : deviceId = map[AccountTable.deviceId],
        email = map[AccountTable.email],
        username = map[AccountTable.username],
        accessToken = map[AccountTable.accessToken],
        refreshToken = map[AccountTable.refreshToken],
        type = AccountType.values[map[AccountTable.type]];

  AccountEntity.guest()
      : deviceId = Ulid().toString(),
        email = null,
        username = null,
        accessToken = null,
        refreshToken = null,
        type = AccountType.Guest;

  AccountEntity.user({
    @required String deviceId,
    @required String email,
    @required String username,
    @required String accessToken,
    @required String refreshToken,
  })  : deviceId = deviceId,
        email = email,
        username = username,
        accessToken = accessToken,
        refreshToken = refreshToken,
        type = AccountType.User;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[AccountTable.deviceId] = deviceId;
    map[AccountTable.email] = email;
    map[AccountTable.username] = username;
    map[AccountTable.accessToken] = accessToken;
    map[AccountTable.refreshToken] = refreshToken;
    map[AccountTable.type] = type.index;

    return map;
  }
}
