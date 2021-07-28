import 'dart:async';

import 'package:flutter_config/flutter_config.dart';
import 'package:sqflite/sqflite.dart';

import '../../fixture/livescore/performance_rating/persistence/tables/fixture_performance_ratings_table.dart';
import '../../fixture/livescore/live_commentary_feed/persistence/tables/live_commentary_feed_entry_table.dart';
import '../../fixture/livescore/live_commentary_feed/persistence/tables/live_commentary_feed_table.dart';
import '../../fixture/livescore/live_commentary_recording/persistence/tables/live_commentary_recording_entry_table.dart';
import '../../fixture/livescore/live_commentary_recording/persistence/tables/live_commentary_recording_table.dart';
import '../../fixture/common/persistence/tables/fixture_table.dart';
import '../../team/persistence/tables/team_table.dart';
import '../../account/persistence/tables/account_table.dart';

class DbConfigurator {
  Database _db;
  Completer _dbOpened;

  Database get db => _db;

  Future _open() async {
    if (FlutterConfig.get('ENVIRONMENT').toLowerCase() == 'development') {
      await deleteDatabase(FlutterConfig.get('DATABASE'));
    }

    _db = await openDatabase(
      FlutterConfig.get('DATABASE'),
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  Future ensureOpen() async {
    if (_dbOpened == null) {
      _dbOpened = Completer();
      try {
        await _open();
        _dbOpened.complete(null);

        return;
      } catch (error) {
        _dbOpened.completeError(error);
        _dbOpened = null;

        rethrow;
      }
    }

    await _dbOpened.future;
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute(AccountTable.createTableCommand);

      await txn.execute(TeamTable.createTableCommand);

      await txn.execute(FixtureTable.createTableCommand);

      await txn.execute(LiveCommentaryRecordingTable.createTableCommand);
      await txn.execute(LiveCommentaryRecordingEntryTable.createTableCommand);

      await txn.execute(LiveCommentaryFeedTable.createTableCommand);
      await txn.execute(LiveCommentaryFeedEntryTable.createTableCommand);

      await txn.execute(FixturePerformanceRatingsTable.createTableCommand);
    });
  }
}
