import '../models/dto/fixture_live_commentary_feed_update_dto.dart';
import '../enums/live_commentary_feed_vote_action.dart';
import '../enums/live_commentary_filter.dart';
import '../models/dto/fixture_live_commentary_feeds_dto.dart';

abstract class ILiveCommentaryFeedApiService {
  Future<FixtureLiveCommentaryFeedsDto> getLiveCommentaryFeedsForFixture(
    int fixtureId,
    int teamId,
    LiveCommentaryFilter filter,
    int start,
  );

  Future<int> voteForLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
    LiveCommentaryFeedVoteAction voteAction,
  );

  Future<Stream<FixtureLiveCommentaryFeedUpdateDto>>
      subscribeToLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
    String lastReceivedEntryId,
  );

  void unsubscribeFromLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
  );
}
