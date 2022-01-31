import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../interfaces/iplayer_rating_repository.dart';
import '../../models/entities/fixture_player_ratings_entity.dart';
import '../tables/fixture_player_ratings_table.dart';
import '../../../../../general/persistence/db_configurator.dart';

class PlayerRatingRepository implements IPlayerRatingRepository {
  final DbConfigurator _dbConfigurator;

  Database get _db => _dbConfigurator.db;

  PlayerRatingRepository(this._dbConfigurator);

  @override
  Future<FixturePlayerRatingsEntity> loadPlayerRatingsForFixture(
    int fixtureId,
    int teamId,
  ) async {
    await _dbConfigurator.ensureOpen();

    List<Map<String, dynamic>> rows = await _db.query(
      FixturePlayerRatingsTable.tableName,
      where:
          '${FixturePlayerRatingsTable.fixtureId} = ? AND ${FixturePlayerRatingsTable.teamId} = ?',
      whereArgs: [fixtureId, teamId],
    );

    return rows.isNotEmpty
        ? FixturePlayerRatingsEntity.fromMap(rows.first)
        : FixturePlayerRatingsEntity.empty(fixtureId, teamId);
  }

  @override
  Future savePlayerRatingsForFixture(
    FixturePlayerRatingsEntity fixturePlayerRatings,
  ) async {
    await _dbConfigurator.ensureOpen();

    await _db.insert(
      FixturePlayerRatingsTable.tableName,
      fixturePlayerRatings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<FixturePlayerRatingsEntity> updatePlayerRating(
    int fixtureId,
    int teamId,
    String participantKey,
    int totalRating,
    int totalVoters,
    double userRating,
  ) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          FixturePlayerRatingsTable.tableName,
          where:
              '${FixturePlayerRatingsTable.fixtureId} = ? AND ${FixturePlayerRatingsTable.teamId} = ?',
          whereArgs: [fixtureId, teamId],
        );

        var fixturePlayerRatings = FixturePlayerRatingsEntity.fromMap(
          rows.first,
        );
        var playerRatings = fixturePlayerRatings.playerRatings;

        var index = playerRatings.indexWhere(
          (pr) => pr.participantKey == participantKey,
        );
        playerRatings[index] = playerRatings[index].copyWith(
          totalRating: totalRating,
          totalVoters: totalVoters,
          userRating: userRating,
        );

        await txn.update(
          FixturePlayerRatingsTable.tableName,
          {
            FixturePlayerRatingsTable.playerRatings: jsonEncode(playerRatings),
          },
          where:
              '${FixturePlayerRatingsTable.fixtureId} = ? AND ${FixturePlayerRatingsTable.teamId} = ?',
          whereArgs: [fixtureId, teamId],
        );

        return fixturePlayerRatings;
      },
      exclusive: true,
    );
  }
}
