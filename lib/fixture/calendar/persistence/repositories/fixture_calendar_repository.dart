import 'package:sqflite/sqflite.dart';

import '../../../common/models/entities/fixture_entity.dart';
import '../../../common/persistence/tables/fixture_table.dart';
import '../../../../general/persistence/db_configurator.dart';
import '../../interfaces/ifixture_calendar_repository.dart';

class FixtureCalendarRepository implements IFixtureCalendarRepository {
  DbConfigurator _dbConfigurator;

  Database get _db => _dbConfigurator.db;

  FixtureCalendarRepository(this._dbConfigurator);

  @override
  Future<Iterable<FixtureEntity>> loadFixturesForTeamInBetween(
    int teamId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    await _dbConfigurator.ensureOpen();

    List<Map<String, dynamic>> rows = await _db.query(
      FixtureTable.tableName,
      columns: [
        FixtureTable.id,
        FixtureTable.leagueName,
        FixtureTable.leagueLogoUrl,
        FixtureTable.opponentTeamId,
        FixtureTable.opponentTeamName,
        FixtureTable.opponentTeamLogoUrl,
        FixtureTable.homeStatus,
        FixtureTable.startTime,
        FixtureTable.status,
        FixtureTable.gameTime,
        FixtureTable.score,
        FixtureTable.venueName,
        FixtureTable.venueImageUrl,
      ],
      where:
          '${FixtureTable.teamId} = ? AND ${FixtureTable.startTime} >= ? AND ${FixtureTable.startTime} < ?',
      whereArgs: [
        teamId,
        startTime.millisecondsSinceEpoch,
        endTime.millisecondsSinceEpoch,
      ],
      orderBy: '${FixtureTable.startTime} ASC',
    );

    return rows.map((row) => FixtureEntity.fromMap(row));
  }

  @override
  Future saveFixtures(Iterable<FixtureEntity> fixtures) async {
    await _dbConfigurator.ensureOpen();

    // @@TODO: StringBuffer.
    var s = '(';
    for (int i = 0; i < fixtures.length; ++i) {
      s += i == 0 ? '?' : ', ?';
    }
    s += ')';

    await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          FixtureTable.tableName,
          columns: [FixtureTable.id],
          where: '${FixtureTable.teamId} = ? AND ${FixtureTable.id} IN $s',
          whereArgs: [
            fixtures.first.teamId,
            ...fixtures.map((fixture) => fixture.id),
          ],
        );

        var batch = txn.batch();

        var existingFixtureIds = rows.map((row) => row[FixtureTable.id]);
        existingFixtureIds.forEach((fixtureId) {
          var fixture = fixtures.firstWhere(
            (fixture) => fixture.id == fixtureId,
          );

          batch.update(
            FixtureTable.tableName,
            fixture.toSummaryMap()
              ..remove(FixtureTable.id)
              ..remove(FixtureTable.teamId)
              ..remove(FixtureTable.isFullyLoaded),
            where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
            whereArgs: [fixture.id, fixture.teamId],
          );
        });

        fixtures
            .where((fixture) => !existingFixtureIds.contains(fixture.id))
            .forEach(
          (fixture) {
            batch.insert(FixtureTable.tableName, fixture.toSummaryMap());
          },
        );

        await batch.commit(noResult: true);
      },
      exclusive: true,
    );
  }
}
