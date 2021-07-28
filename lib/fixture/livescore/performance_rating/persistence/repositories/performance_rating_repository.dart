import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../interfaces/iperformance_rating_repository.dart';
import '../../models/entities/fixture_performance_ratings_entity.dart';
import '../tables/fixture_performance_ratings_table.dart';
import '../../../../../general/persistence/db_configurator.dart';

class PerformanceRatingRepository implements IPerformanceRatingRepository {
  final DbConfigurator _dbConfigurator;

  Database get _db => _dbConfigurator.db;

  PerformanceRatingRepository(this._dbConfigurator);

  @override
  Future<FixturePerformanceRatingsEntity> loadPerformanceRatingsForFixture(
    int fixtureId,
    int teamId,
  ) async {
    await _dbConfigurator.ensureOpen();

    List<Map<String, dynamic>> rows = await _db.query(
      FixturePerformanceRatingsTable.tableName,
      where:
          '${FixturePerformanceRatingsTable.fixtureId} = ? AND ${FixturePerformanceRatingsTable.teamId} = ?',
      whereArgs: [fixtureId, teamId],
    );

    return rows.isNotEmpty
        ? FixturePerformanceRatingsEntity.fromMap(rows.first)
        : FixturePerformanceRatingsEntity.empty(fixtureId, teamId);
  }

  @override
  Future savePerformanceRatingsForFixture(
    FixturePerformanceRatingsEntity fixturePerformanceRatings,
  ) async {
    await _dbConfigurator.ensureOpen();

    await _db.insert(
      FixturePerformanceRatingsTable.tableName,
      fixturePerformanceRatings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<FixturePerformanceRatingsEntity>
      updatePerformanceRatingForFixtureParticipant(
    int fixtureId,
    int teamId,
    String participantIdentifier,
    int totalRating,
    int totalVoters,
    double myRating,
  ) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          FixturePerformanceRatingsTable.tableName,
          where:
              '${FixturePerformanceRatingsTable.fixtureId} = ? AND ${FixturePerformanceRatingsTable.teamId} = ?',
          whereArgs: [fixtureId, teamId],
        );

        var fixturePerformanceRatings =
            FixturePerformanceRatingsEntity.fromMap(rows.first);
        var performanceRatings = fixturePerformanceRatings.performanceRatings;

        var index = performanceRatings.indexWhere(
          (pr) => pr.participantIdentifier == participantIdentifier,
        );
        performanceRatings[index] = performanceRatings[index].copyWith(
          totalRating: totalRating,
          totalVoters: totalVoters,
          myRating: myRating,
        );

        await txn.update(
          FixturePerformanceRatingsTable.tableName,
          {
            FixturePerformanceRatingsTable.performanceRatings:
                jsonEncode(performanceRatings)
          },
          where:
              '${FixturePerformanceRatingsTable.fixtureId} = ? AND ${FixturePerformanceRatingsTable.teamId} = ?',
          whereArgs: [fixtureId, teamId],
        );

        return fixturePerformanceRatings;
      },
      exclusive: true,
    );
  }
}
