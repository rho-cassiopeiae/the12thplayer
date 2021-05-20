import 'dart:async';

import 'package:flutter_config/flutter_config.dart';
import 'package:sqflite/sqflite.dart';

import '../../fixture/livescore/video_reaction/persistence/tables/fixture_video_reaction_votes_table.dart';
import '../../fixture/livescore/live_commentary_feed/persistence/tables/fixture_live_commentary_feed_votes_table.dart';
import '../../fixture/livescore/live_commentary_feed/persistence/tables/live_commentary_feed_entry_table.dart';
import '../../fixture/livescore/live_commentary_feed/persistence/tables/live_commentary_feed_table.dart';
import '../../fixture/livescore/live_commentary_recording/persistence/tables/live_commentary_recording_entry_table.dart';
import '../../fixture/livescore/live_commentary_recording/persistence/tables/live_commentary_recording_table.dart';
import '../../fixture/common/persistence/tables/fixture_table.dart';
import 'tables/team_table.dart';
import '../../account/persistence/tables/account_table.dart';

class DbConfigurator {
  Database _db;
  Completer _dbOpened;

  Database get db => _db;

  Future _open() async {
    await deleteDatabase(
      FlutterConfig.get('DATABASE'),
    ); // @@!!: Remove for prod!

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
      // @@TODO: Allow to choose between multiple teams on first app startup.
      // Should be able to switch team at any point.
      // For now there is only one supported team.
      await txn.insert(
        TeamTable.tableName,
        {
          TeamTable.id: 18,
          TeamTable.name: 'Chelsea',
          TeamTable.logoUrl:
              'https://cdn.sportmonks.com/images/soccer/teams/18/18.png',
          TeamTable.currentlySelected: 1,
        },
      );

      await txn.execute(FixtureTable.createTableCommand);

      await txn.execute(LiveCommentaryRecordingTable.createTableCommand);
      await txn.execute(LiveCommentaryRecordingEntryTable.createTableCommand);

      await txn.execute(LiveCommentaryFeedTable.createTableCommand);
      await txn.execute(LiveCommentaryFeedEntryTable.createTableCommand);

      await txn.execute(FixtureLiveCommentaryFeedVotesTable.createTableCommand);

      await txn.execute(FixtureVideoReactionVotesTable.createTableCommand);
    });
  }
}
