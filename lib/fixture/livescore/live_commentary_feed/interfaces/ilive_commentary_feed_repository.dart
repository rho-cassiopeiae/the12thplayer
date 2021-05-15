import '../models/entities/live_commentary_feed_entry_entity.dart';
import '../models/entities/live_commentary_feed_entity.dart';
import '../enums/live_commentary_feed_vote_action.dart';
import '../models/entities/fixture_live_commentary_feed_votes_entity.dart';

abstract class ILiveCommentaryFeedRepository {
  Future<FixtureLiveCommentaryFeedVotesEntity>
      loadLiveCommentaryFeedVotesForFixture(
    int fixtureId,
    int teamId,
  );

  Future<LiveCommentaryFeedVoteAction> updateVoteActionForLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
    LiveCommentaryFeedVoteAction voteAction,
  );

  Future<LiveCommentaryFeedEntity> loadLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
  );

  Future addLiveCommentaryFeedEntries(
    Iterable<LiveCommentaryFeedEntryEntity> entries,
  );
}
