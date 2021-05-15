import 'package:either_option/either_option.dart';

import '../../../../account/services/account_service.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/utils/policy.dart';
import '../models/entities/live_commentary_feed_entity.dart';
import '../models/vm/live_commentary_feed_entry_vm.dart';
import '../enums/live_commentary_feed_vote_action.dart';
import '../enums/live_commentary_filter.dart';
import '../interfaces/ilive_commentary_feed_api_service.dart';
import '../models/vm/fixture_live_commentary_feeds_vm.dart';
import '../../../../general/persistence/storage.dart';
import '../../../../general/errors/error.dart';

class LiveCommentaryFeedService {
  final Storage _storage;
  final ILiveCommentaryFeedApiService _liveCommentaryFeedApiService;
  final AccountService _accountService;

  PolicyExecutor<AuthenticationTokenExpiredError> _wsApiPolicy;

  LiveCommentaryFeedService(
    this._storage,
    this._liveCommentaryFeedApiService,
    this._accountService,
  ) {
    _wsApiPolicy = Policy.on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: _accountService.refreshAccessToken,
        ),
      ],
    );
  }

  Future<Either<Error, FixtureLiveCommentaryFeedsVm>> loadLiveCommentaryFeeds(
    int fixtureId,
    LiveCommentaryFilter filter,
    int start,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var fixtureLiveCommFeedsDto =
          await _liveCommentaryFeedApiService.getLiveCommentaryFeedsForFixture(
        fixtureId,
        currentTeam.id,
        filter,
        start,
      );

      var fixtureLiveCommFeedVotes =
          await _storage.loadLiveCommentaryFeedVotesForFixture(
        fixtureId,
        currentTeam.id,
      );

      var fixtureLiveCommFeedsVm = FixtureLiveCommentaryFeedsVm.fromDto(
        fixtureLiveCommFeedsDto,
        fixtureLiveCommFeedVotes.authorIdToVoteAction,
      );

      return Right(fixtureLiveCommFeedsVm);
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Stream<Either<Error, FixtureLiveCommentaryFeedsVm>> voteForLiveCommentaryFeed(
    int fixtureId,
    int authorId,
    LiveCommentaryFeedVoteAction voteAction,
    FixtureLiveCommentaryFeedsVm fixtureLiveCommFeeds,
  ) async* {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var oldVoteAction = await _storage.updateVoteActionForLiveCommentaryFeed(
        fixtureId,
        currentTeam.id,
        authorId,
        voteAction,
      );

      if (oldVoteAction != null) {
        if (voteAction == oldVoteAction) {
          voteAction =
              LiveCommentaryFeedVoteAction.values[voteAction.index + 2];
        } else {
          voteAction =
              LiveCommentaryFeedVoteAction.values[voteAction.index + 4];
        }
      }

      int incrScoreBy;
      switch (voteAction) {
        case LiveCommentaryFeedVoteAction.Upvote:
          incrScoreBy = 1;
          break;
        case LiveCommentaryFeedVoteAction.Downvote:
          incrScoreBy = -1;
          break;
        case LiveCommentaryFeedVoteAction.RevertUpvote:
          incrScoreBy = -1;
          break;
        case LiveCommentaryFeedVoteAction.RevertDownvote:
          incrScoreBy = 1;
          break;
        case LiveCommentaryFeedVoteAction.RevertDownvoteAndThenUpvote:
          incrScoreBy = 2;
          break;
        case LiveCommentaryFeedVoteAction.RevertUpvoteAndThenDownvote:
          incrScoreBy = -2;
          break;
      }

      var feeds = fixtureLiveCommFeeds.feeds;
      var index = feeds.indexWhere((feed) => feed.authorId == authorId);
      var feed = feeds[index];
      feeds[index] = feed.copyWith(
        rating: feed.rating + incrScoreBy,
        voteAction: voteAction,
      );

      feeds.sort((f1, f2) => f2.rating.compareTo(f1.rating));

      yield Right(fixtureLiveCommFeeds);

      int rating = await _wsApiPolicy.execute(
        () => _liveCommentaryFeedApiService.voteForLiveCommentaryFeed(
          fixtureId,
          currentTeam.id,
          authorId,
          voteAction,
        ),
      );

      fixtureLiveCommFeeds = fixtureLiveCommFeeds.copy();
      feeds = fixtureLiveCommFeeds.feeds;
      index = feeds.indexWhere((feed) => feed.authorId == authorId);
      feeds[index] = feeds[index].copyWith(rating: rating);
      feeds.sort((f1, f2) => f2.rating.compareTo(f1.rating));

      yield Right(fixtureLiveCommFeeds);
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      yield Left(Error(error.toString()));
    }
  }

  Future<Either<Error, List<LiveCommentaryFeedEntryVm>>> loadLiveCommentaryFeed(
    int fixtureId,
    int authorId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var feed = await _storage.loadLiveCommentaryFeed(
        fixtureId,
        currentTeam.id,
        authorId,
      );

      return Right(
        feed.entries
            .map((entry) => LiveCommentaryFeedEntryVm.fromEntity(entry))
            .toList(),
      );
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Stream<Either<Error, List<LiveCommentaryFeedEntryVm>>>
      subscribeToLiveCommentaryFeed(
    int fixtureId,
    int authorId,
    String lastReceivedEntryId,
  ) async* {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      await for (var update
          in await _liveCommentaryFeedApiService.subscribeToLiveCommentaryFeed(
        fixtureId,
        currentTeam.id,
        authorId,
        lastReceivedEntryId,
      )) {
        var feed = LiveCommentaryFeedEntity.fromUpdateDto(update);

        await _storage.addLiveCommentaryFeedEntries(feed.entries);

        feed = await _storage.loadLiveCommentaryFeed(
          fixtureId,
          currentTeam.id,
          authorId,
        );

        yield Right(
          feed.entries
              .map((entry) => LiveCommentaryFeedEntryVm.fromEntity(entry))
              .toList(),
        );
      }
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      yield Left(Error(error.toString()));
    }
  }

  void unsubscribeFromLiveCommentaryFeed(int fixtureId, int authorId) async {
    var currentTeam = await _storage.loadCurrentTeam();
    _liveCommentaryFeedApiService.unsubscribeFromLiveCommentaryFeed(
      fixtureId,
      currentTeam.id,
      authorId,
    );
  }
}
