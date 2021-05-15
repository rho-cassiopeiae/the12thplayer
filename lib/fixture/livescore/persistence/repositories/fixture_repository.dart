import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../common/models/entities/fixture_entity.dart';
import '../../../common/models/entities/performance_rating_entity.dart';
import '../../../common/persistence/tables/fixture_table.dart';
import '../../interfaces/ifixture_repository.dart';
import '../../../../general/persistence/db_configurator.dart';

class FixtureRepository implements IFixtureRepository {
  DbConfigurator _dbConfigurator;

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
  Future<FixtureEntity> updateFixture(FixtureEntity fixture) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          FixtureTable.tableName,
          columns: [FixtureTable.performanceRatings],
          where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
          whereArgs: [fixture.id, fixture.teamId],
        );

        var row = rows.first;
        var existingPerformanceRatings = row[FixtureTable.performanceRatings] ==
                null
            ? null
            : (jsonDecode(row[FixtureTable.performanceRatings])
                    as List<dynamic>)
                .map((ratingMap) => PerformanceRatingEntity.fromMap(ratingMap))
                .toList();

        if (fixture.performanceRatings.isNotEmpty) {
          if (existingPerformanceRatings == null ||
              existingPerformanceRatings.isEmpty) {
            existingPerformanceRatings = fixture.performanceRatings;
          } else {
            for (var performanceRating in fixture.performanceRatings) {
              var index = existingPerformanceRatings.indexWhere(
                (existingRating) =>
                    existingRating.participantIdentifier ==
                    performanceRating.participantIdentifier,
              );

              if (fixture.isFullyLoaded) {
                if (index >= 0) {
                  // if there is an existing rating for a participant
                  // update it with new 'total' values but remember to preserve
                  // 'myRating' if any
                  existingPerformanceRatings[index] =
                      existingPerformanceRatings[index].copyWith(
                    totalRating: performanceRating.totalRating,
                    totalVoters: performanceRating.totalVoters,
                  );
                } else {
                  existingPerformanceRatings.add(performanceRating);
                }
              } else {
                if (index == -1) {
                  existingPerformanceRatings.add(performanceRating);
                }
              }
            }
          }
        }

        var updatedFixture = fixture.copyWith(
          performanceRatings: existingPerformanceRatings,
        );

        await txn.update(
          FixtureTable.tableName,
          updatedFixture.toFullMap()
            ..remove(FixtureTable.id)
            ..remove(FixtureTable.teamId),
          where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
          whereArgs: [fixture.id, fixture.teamId],
        );

        return updatedFixture;
      },
      exclusive: true,
    );
  }

  @override
  Future<FixtureEntity> updateFixtureFromLivescore(
    FixtureEntity fixture,
  ) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          FixtureTable.tableName,
          columns: [FixtureTable.performanceRatings],
          where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
          whereArgs: [fixture.id, fixture.teamId],
        );

        var row = rows.first;
        var existingPerformanceRatings = row[FixtureTable.performanceRatings] ==
                null
            ? null
            : (jsonDecode(row[FixtureTable.performanceRatings])
                    as List<dynamic>)
                .map((ratingMap) => PerformanceRatingEntity.fromMap(ratingMap))
                .toList();

        if (fixture.performanceRatings.isNotEmpty) {
          if (existingPerformanceRatings == null ||
              existingPerformanceRatings.isEmpty) {
            existingPerformanceRatings = fixture.performanceRatings;
          } else {
            for (var performanceRating in fixture.performanceRatings) {
              var index = existingPerformanceRatings.indexWhere(
                (existingRating) =>
                    existingRating.participantIdentifier ==
                    performanceRating.participantIdentifier,
              );
              if (index == -1) {
                existingPerformanceRatings.add(performanceRating);
              }
            }
          }
        }

        var updatedFixture = fixture.copyWith(
          performanceRatings: existingPerformanceRatings,
        );

        await txn.update(
          FixtureTable.tableName,
          updatedFixture.toLivescoreUpdateMap()
            ..remove(FixtureTable.id)
            ..remove(FixtureTable.teamId),
          where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
          whereArgs: [fixture.id, fixture.teamId],
        );

        rows = await txn.query(
          FixtureTable.tableName,
          where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
          whereArgs: [fixture.id, fixture.teamId],
        );

        return FixtureEntity.fromMap(rows.first);
      },
      exclusive: true,
    );
  }

  @override
  Future<double> updateMyRatingOfParticipantOfGivenFixture(
    int fixtureId,
    int teamId,
    String participantIdentifier,
    double rating,
  ) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          FixtureTable.tableName,
          columns: [FixtureTable.performanceRatings],
          where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
          whereArgs: [fixtureId, teamId],
        );

        var performanceRatings = (jsonDecode(
          rows.first[FixtureTable.performanceRatings],
        ) as List<dynamic>)
            .map((ratingMap) => PerformanceRatingEntity.fromMap(ratingMap))
            .toList();

        // @@NOTE: performanceRatings cannot be null here and index is guaranteed to be >= 0.

        var index = performanceRatings.indexWhere(
          (performanceRating) =>
              performanceRating.participantIdentifier == participantIdentifier,
        );

        double oldRating = performanceRatings[index].myRating;
        performanceRatings[index] =
            performanceRatings[index].copyWith(myRating: rating);

        await txn.update(
          FixtureTable.tableName,
          {
            FixtureTable.performanceRatings: jsonEncode(performanceRatings),
          },
          where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
          whereArgs: [fixtureId, teamId],
        );

        return oldRating;
      },
      exclusive: true,
    );
  }

  @override
  Future updateRatingOfParticipantOfGivenFixture(
    int fixtureId,
    int teamId,
    String participantIdentifier,
    int totalRating,
    int totalVoters,
  ) async {
    await _dbConfigurator.ensureOpen();

    await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          FixtureTable.tableName,
          columns: [FixtureTable.performanceRatings],
          where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
          whereArgs: [fixtureId, teamId],
        );

        var performanceRatings = (jsonDecode(
          rows.first[FixtureTable.performanceRatings],
        ) as List<dynamic>)
            .map((ratingMap) => PerformanceRatingEntity.fromMap(ratingMap))
            .toList();

        var index = performanceRatings.indexWhere(
          (performanceRating) =>
              performanceRating.participantIdentifier == participantIdentifier,
        );

        performanceRatings[index] = performanceRatings[index].copyWith(
          totalRating: totalRating,
          totalVoters: totalVoters,
        );

        await txn.update(
          FixtureTable.tableName,
          {
            FixtureTable.performanceRatings: jsonEncode(performanceRatings),
          },
          where: '${FixtureTable.id} = ? AND ${FixtureTable.teamId} = ?',
          whereArgs: [fixtureId, teamId],
        );
      },
      exclusive: true,
    );
  }
}
