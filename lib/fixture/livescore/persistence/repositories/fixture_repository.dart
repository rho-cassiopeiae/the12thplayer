import 'package:sqflite/sqflite.dart';

import '../../../common/models/entities/fixture_entity.dart';
import '../../../common/persistence/tables/fixture_table.dart';
import '../../interfaces/ifixture_repository.dart';
import '../../../../general/persistence/db_configurator.dart';

class FixtureRepository implements IFixtureRepository {
  final DbConfigurator _dbConfigurator;

  Database get _db => _dbConfigurator.db;

  FixtureRepository(this._dbConfigurator);

  @override
  Future<FixtureEntity> loadFixtureForTeam(int fixtureId, int teamId) async {
    await _dbConfigurator.ensureOpen();

    List<Map<String, dynamic>> rows = await _db.query(
      FixtureTable.tableName,
      where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
      whereArgs: [fixtureId, teamId],
    );

    return FixtureEntity.fromMap(rows.first);
  }

  @override
  Future updateFixture(FixtureEntity fixture) async {
    await _dbConfigurator.ensureOpen();

    await _db.update(
      FixtureTable.tableName,
      fixture.toFullMap()..remove(FixtureTable.id)..remove(FixtureTable.teamId),
      where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
      whereArgs: [fixture.id, fixture.teamId],
    );
  }

  @override
  Future<FixtureEntity> updateFixtureFromLivescore(
    FixtureEntity fixture,
  ) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        await txn.update(
          FixtureTable.tableName,
          fixture.toLivescoreUpdateMap()
            ..remove(FixtureTable.id)
            ..remove(FixtureTable.teamId),
          where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
          whereArgs: [fixture.id, fixture.teamId],
        );

        List<Map<String, dynamic>> rows = await txn.query(
          FixtureTable.tableName,
          where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
          whereArgs: [fixture.id, fixture.teamId],
        );

        return FixtureEntity.fromMap(rows.first);
      },
      exclusive: true,
    );
  }
}
