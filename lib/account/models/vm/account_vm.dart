import '../entities/account_entity.dart';
import '../../enums/account_type.dart';

class AccountVm {
  final String email;
  final String username;
  final String accessToken;
  final String refreshToken;
  final AccountType type;

  AccountVm.fromEntity(AccountEntity account)
      : email = account.email,
        username = account.username,
        accessToken = account.accessToken,
        refreshToken = account.refreshToken,
        type = account.type;
}
