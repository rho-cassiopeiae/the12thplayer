import 'package:sqflite/sqflite.dart';

import '../tables/account_table.dart';
import '../../models/entities/account_entity.dart';
import '../../../general/persistence/db_configurator.dart';
import '../../interfaces/iaccount_repository.dart';

class AccountRepository implements IAccountRepository {
  DbConfigurator _dbConfigurator;

  Database get _db => _dbConfigurator.db;

  AccountRepository(this._dbConfigurator);

  @override
  Future<AccountEntity> loadAccount() async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          AccountTable.tableName,
        );

        AccountEntity account;
        if (rows.isEmpty) {
          account = AccountEntity.guest();
          await txn.insert(AccountTable.tableName, account.toMap());
        } else {
          account = AccountEntity.fromMap(rows.first);
        }

        return account;
      },
      exclusive: true,
    );
  }

  @override
  Future saveAccount(AccountEntity account) async {
    await _dbConfigurator.ensureOpen();
    await _db.update(AccountTable.tableName, account.toMap());
  }
}
