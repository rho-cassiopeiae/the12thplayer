import 'package:sqflite/sqflite.dart';

import '../../enums/live_commentary_feed_vote_action.dart';
import '../../models/entities/live_commentary_feed_entity.dart';
import '../../models/entities/live_commentary_feed_entry_entity.dart';
import '../tables/live_commentary_feed_entry_table.dart';
import '../tables/live_commentary_feed_table.dart';
import '../../interfaces/ilive_commentary_feed_repository.dart';
import '../../models/entities/fixture_live_commentary_feed_votes_entity.dart';
import '../tables/fixture_live_commentary_feed_votes_table.dart';
import '../../../../../general/persistence/db_configurator.dart';

class LiveCommentaryFeedRepository implements ILiveCommentaryFeedRepository {
  DbConfigurator _dbConfigurator;

  Database get _db => _dbConfigurator.db;

  LiveCommentaryFeedRepository(this._dbConfigurator);

  @override
  Future<FixtureLiveCommentaryFeedVotesEntity>
      loadLiveCommentaryFeedVotesForFixture(
    int fixtureId,
    int teamId,
  ) async {
    await _dbConfigurator.ensureOpen();

    List<Map<String, dynamic>> rows = await _db.query(
      FixtureLiveCommentaryFeedVotesTable.tableName,
      where:
          '${FixtureLiveCommentaryFeedVotesTable.fixtureId} = ? AND ${FixtureLiveCommentaryFeedVotesTable.teamId} = ?',
      whereArgs: [fixtureId, teamId],
    );

    return rows.isEmpty
        ? FixtureLiveCommentaryFeedVotesEntity.noVotes(
            fixtureId: fixtureId,
            teamId: teamId,
          )
        : FixtureLiveCommentaryFeedVotesEntity.fromMap(rows.first);
  }

  @override
  Future<LiveCommentaryFeedVoteAction> updateVoteActionForLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
    LiveCommentaryFeedVoteAction voteAction,
  ) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          FixtureLiveCommentaryFeedVotesTable.tableName,
          where:
              '${FixtureLiveCommentaryFeedVotesTable.fixtureId} = ? AND ${FixtureLiveCommentaryFeedVotesTable.teamId} = ?',
          whereArgs: [fixtureId, teamId],
        );

        var fixtureLiveCommFeedVotes = rows.isEmpty
            ? FixtureLiveCommentaryFeedVotesEntity.noVotes(
                fixtureId: fixtureId,
                teamId: teamId,
              )
            : FixtureLiveCommentaryFeedVotesEntity.fromMap(rows.first);

        var authorIdToVoteAction =
            fixtureLiveCommFeedVotes.authorIdToVoteAction;
        LiveCommentaryFeedVoteAction oldVoteAction;
        if (authorIdToVoteAction.containsKey(authorId)) {
          oldVoteAction = authorIdToVoteAction[authorId];
          if (voteAction == oldVoteAction) {
            authorIdToVoteAction.remove(authorId);
          } else {
            authorIdToVoteAction[authorId] = voteAction;
          }
        } else {
          authorIdToVoteAction[authorId] = voteAction;
        }

        await txn.insert(
          FixtureLiveCommentaryFeedVotesTable.tableName,
          fixtureLiveCommFeedVotes.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        return oldVoteAction;
      },
      exclusive: true,
    );
  }

  @override
  Future<LiveCommentaryFeedEntity> loadLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
  ) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.rawQuery(
          '''
            SELECT
              l.${LiveCommentaryFeedTable.fixtureId} AS ${LiveCommentaryFeedTable.fixtureId},
              l.${LiveCommentaryFeedTable.teamId} AS ${LiveCommentaryFeedTable.teamId},
              l.${LiveCommentaryFeedTable.authorId} AS ${LiveCommentaryFeedTable.authorId},
              e.${LiveCommentaryFeedEntryTable.idTime} AS ${LiveCommentaryFeedEntryTable.idTime},
              e.${LiveCommentaryFeedEntryTable.idSeq} AS ${LiveCommentaryFeedEntryTable.idSeq},
              e.${LiveCommentaryFeedEntryTable.time} AS ${LiveCommentaryFeedEntryTable.time},
              e.${LiveCommentaryFeedEntryTable.icon} AS ${LiveCommentaryFeedEntryTable.icon},
              e.${LiveCommentaryFeedEntryTable.title} AS ${LiveCommentaryFeedEntryTable.title},
              e.${LiveCommentaryFeedEntryTable.body} AS ${LiveCommentaryFeedEntryTable.body},
              e.${LiveCommentaryFeedEntryTable.imageUrl} AS ${LiveCommentaryFeedEntryTable.imageUrl}
            FROM
              ${LiveCommentaryFeedTable.tableName} l
              LEFT JOIN
              ${LiveCommentaryFeedEntryTable.tableName} e
                ON (
                  l.${LiveCommentaryFeedTable.fixtureId} = e.${LiveCommentaryFeedEntryTable.fixtureId}
                  AND
                  l.${LiveCommentaryFeedTable.teamId} = e.${LiveCommentaryFeedEntryTable.teamId}
                  AND
                  l.${LiveCommentaryFeedTable.authorId} = e.${LiveCommentaryFeedEntryTable.authorId}
                )
            WHERE l.${LiveCommentaryFeedTable.fixtureId} = ? AND l.${LiveCommentaryFeedTable.teamId} = ? AND l.${LiveCommentaryFeedTable.authorId} = ?
            ORDER BY e.${LiveCommentaryFeedEntryTable.idTime} DESC, e.${LiveCommentaryFeedEntryTable.idSeq} DESC
          ''',
          [fixtureId, teamId, authorId],
        );

        LiveCommentaryFeedEntity feed;
        if (rows.isNotEmpty) {
          Iterable<LiveCommentaryFeedEntryEntity> entries = [];
          if (rows.first[LiveCommentaryFeedEntryTable.idTime] != null) {
            entries = rows.map(
              (row) => LiveCommentaryFeedEntryEntity.fromMap(row),
            );
          }
          feed = LiveCommentaryFeedEntity.fromMap(rows.first, entries);
        } else {
          feed = LiveCommentaryFeedEntity.noEntries(
            fixtureId: fixtureId,
            teamId: teamId,
            authorId: authorId,
          );

          await txn.insert(LiveCommentaryFeedTable.tableName, feed.toMap());
        }

        return feed;
      },
      exclusive: true,
    );
  }

  @override
  Future addLiveCommentaryFeedEntries(
    Iterable<LiveCommentaryFeedEntryEntity> entries,
  ) async {
    await _dbConfigurator.ensureOpen();

    var batch = _db.batch();

    entries.forEach((entry) {
      batch.insert(
        LiveCommentaryFeedEntryTable.tableName,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  }
}
