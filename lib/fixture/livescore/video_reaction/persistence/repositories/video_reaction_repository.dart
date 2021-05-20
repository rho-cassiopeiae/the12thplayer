import 'package:sqflite/sqflite.dart';

import '../../enums/video_reaction_vote_action.dart';
import '../../interfaces/ivideo_reaction_repository.dart';
import '../../models/entities/fixture_video_reaction_votes_entity.dart';
import '../tables/fixture_video_reaction_votes_table.dart';
import '../../../../../general/persistence/db_configurator.dart';

class VideoReactionRepository implements IVideoReactionRepository {
  DbConfigurator _dbConfigurator;

  Database get _db => _dbConfigurator.db;

  VideoReactionRepository(this._dbConfigurator);

  @override
  Future<FixtureVideoReactionVotesEntity> loadVideoReactionVotesForFixture(
    int fixtureId,
    int teamId,
  ) async {
    await _dbConfigurator.ensureOpen();

    List<Map<String, dynamic>> rows = await _db.query(
      FixtureVideoReactionVotesTable.tableName,
      where:
          '${FixtureVideoReactionVotesTable.fixtureId} = ? AND ${FixtureVideoReactionVotesTable.teamId} = ?',
      whereArgs: [fixtureId, teamId],
    );

    return rows.isEmpty
        ? FixtureVideoReactionVotesEntity.noVotes(
            fixtureId: fixtureId,
            teamId: teamId,
          )
        : FixtureVideoReactionVotesEntity.fromMap(rows.first);
  }

  @override
  Future<VideoReactionVoteAction> updateVoteActionForVideoReaction(
    int fixtureId,
    int teamId,
    int authorId,
    VideoReactionVoteAction voteAction,
  ) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          FixtureVideoReactionVotesTable.tableName,
          where:
              '${FixtureVideoReactionVotesTable.fixtureId} = ? AND ${FixtureVideoReactionVotesTable.teamId} = ?',
          whereArgs: [fixtureId, teamId],
        );

        var fixtureVideoReactionVotes = rows.isEmpty
            ? FixtureVideoReactionVotesEntity.noVotes(
                fixtureId: fixtureId,
                teamId: teamId,
              )
            : FixtureVideoReactionVotesEntity.fromMap(rows.first);

        var authorIdToVoteAction =
            fixtureVideoReactionVotes.authorIdToVoteAction;
        VideoReactionVoteAction oldVoteAction;
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
          FixtureVideoReactionVotesTable.tableName,
          fixtureVideoReactionVotes.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        return oldVoteAction;
      },
      exclusive: true,
    );
  }
}
