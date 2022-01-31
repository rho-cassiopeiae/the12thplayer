import '../entities/account_entity.dart';
import '../../enums/account_type.dart';

class AccountVm {
  final String email;
  final String username;
  final AccountType type;

  AccountVm.fromEntity(AccountEntity account)
      : email = account.email,
        username = account.username,
        type = account.type;
}
