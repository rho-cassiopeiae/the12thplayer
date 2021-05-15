import '../models/entities/account_entity.dart';

abstract class IAccountRepository {
  Future<AccountEntity> loadAccount();
  Future saveAccount(AccountEntity account);
}
