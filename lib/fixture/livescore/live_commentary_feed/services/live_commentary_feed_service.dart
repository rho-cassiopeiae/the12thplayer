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

  Policy _wsApiPolicy;

  LiveCommentaryFeedService(
    this._storage,
    this._liveCommentaryFeedApiService,
    this._accountService,
  ) {
    _wsApiPolicy = PolicyBuilder().on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: _accountService.refreshAccessToken,
        ),
      ],
    ).build();
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

      return Right(
        FixtureLiveCommentaryFeedsVm.fromDto(fixtureLiveCommFeedsDto),
      );
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

      var feeds = fixtureLiveCommFeeds.feeds;
      var index = feeds.indexWhere((feed) => feed.authorId == authorId);
      var feed = feeds[index];

      var oldVoteAction = feed.voteAction;
      LiveCommentaryFeedVoteAction newVoteAction;
      int incrScoreBy;
      if (oldVoteAction == null) {
        newVoteAction = voteAction;
        incrScoreBy = voteAction.toInt();
      } else if (voteAction == oldVoteAction) {
        incrScoreBy = -voteAction.toInt();
      } else {
        newVoteAction = voteAction;
        incrScoreBy = voteAction.toInt() * 2;
      }

      feeds[index] = feed.copyWith(
        rating: feed.rating + incrScoreBy,
        voteAction: newVoteAction,
      );

      feeds.sort((f1, f2) => f2.rating.compareTo(f1.rating));

      yield Right(fixtureLiveCommFeeds);

      var result = await _wsApiPolicy.execute(
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

      feeds[index] = feeds[index].copyWith(
        rating: result.updatedRating,
        voteAction: LiveCommentaryFeedVoteActionExtension.fromInt(
          result.updatedVoteAction,
        ),
      );

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
