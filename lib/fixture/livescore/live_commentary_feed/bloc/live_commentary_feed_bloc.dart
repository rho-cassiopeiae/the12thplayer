import 'dart:async';

import 'live_commentary_feed_actions.dart';
import 'live_commentary_feed_states.dart';
import '../services/live_commentary_feed_service.dart';
import '../../../../general/bloc/bloc.dart';

class LiveCommentaryFeedBloc extends Bloc<LiveCommentaryFeedAction> {
  final LiveCommentaryFeedService _liveCommentaryFeedService;

  StreamController<LoadLiveCommentaryFeedsState> _feedsStateChannel =
      StreamController<LoadLiveCommentaryFeedsState>.broadcast();
  Stream<LoadLiveCommentaryFeedsState> get feedsState$ =>
      _feedsStateChannel.stream;

  StreamController<LoadLiveCommentaryFeedState> _feedStateChannel =
      StreamController<LoadLiveCommentaryFeedState>.broadcast();
  Stream<LoadLiveCommentaryFeedState> get feedState$ =>
      _feedStateChannel.stream;

  LiveCommentaryFeedBloc(this._liveCommentaryFeedService) {
    actionChannel.stream.listen((action) {
      if (action is LoadLiveCommentaryFeeds) {
        _loadLiveCommentaryFeeds(action);
      } else if (action is VoteForLiveCommentaryFeed) {
        _voteForLiveCommentaryFeed(action);
      } else if (action is LoadLiveCommentaryFeed) {
        _loadLiveCommentaryFeed(action);
      } else if (action is SubscribeToLiveCommentaryFeed) {
        _subscribeToLiveCommentaryFeed(action);
      } else if (action is UnsubscribeFromLiveCommentaryFeed) {
        _unsubscribeFromLiveCommentaryFeed(action);
        actionChannel.close();
        actionChannel = null;
      }
    });
  }

  @override
  void dispose({LiveCommentaryFeedAction cleanupAction}) {
    _feedsStateChannel.close();
    _feedsStateChannel = null;
    _feedStateChannel.close();
    _feedStateChannel = null;

    if (cleanupAction != null) {
      dispatchAction(cleanupAction);
    } else {
      actionChannel.close();
      actionChannel = null;
    }
  }

  void _loadLiveCommentaryFeeds(LoadLiveCommentaryFeeds action) async {
    var result = await _liveCommentaryFeedService.loadLiveCommentaryFeeds(
      action.fixtureId,
      action.filter,
      action.start,
    );

    var state = result.fold(
      (error) => LiveCommentaryFeedsError(message: error.toString()),
      (fixtureLiveCommFeeds) => LiveCommentaryFeedsReady(
        fixtureLiveCommentaryFeeds: fixtureLiveCommFeeds,
      ),
    );

    _feedsStateChannel?.add(state);
  }

  void _voteForLiveCommentaryFeed(VoteForLiveCommentaryFeed action) async {
    await for (var result
        in _liveCommentaryFeedService.voteForLiveCommentaryFeed(
      action.fixtureId,
      action.authorId,
      action.voteAction,
      action.fixtureLiveCommentaryFeeds,
    )) {
      var state = result.fold(
        (error) => LiveCommentaryFeedsError(message: error.toString()),
        (fixtureLiveCommFeeds) => LiveCommentaryFeedsReady(
          fixtureLiveCommentaryFeeds: fixtureLiveCommFeeds,
        ),
      );

      _feedsStateChannel?.add(state);
    }
  }

  void _loadLiveCommentaryFeed(LoadLiveCommentaryFeed action) async {
    var result = await _liveCommentaryFeedService.loadLiveCommentaryFeed(
      action.fixtureId,
      action.authorId,
    );
    var state = result.fold(
      (error) => LiveCommentaryFeedError(message: error.toString()),
      (entries) => LiveCommentaryFeedReady(entries: entries),
    );

    action.complete(state);
    _feedStateChannel?.add(state);
  }

  void _subscribeToLiveCommentaryFeed(
    SubscribeToLiveCommentaryFeed action,
  ) async {
    await for (var update
        in _liveCommentaryFeedService.subscribeToLiveCommentaryFeed(
      action.fixtureId,
      action.authorId,
      action.lastReceivedEntryId,
    )) {
      var state = update.fold(
        (error) => LiveCommentaryFeedError(message: error.toString()),
        (entries) => LiveCommentaryFeedReady(entries: entries),
      );

      _feedStateChannel?.add(state);
    }
  }

  void _unsubscribeFromLiveCommentaryFeed(
    UnsubscribeFromLiveCommentaryFeed action,
  ) {
    _liveCommentaryFeedService.unsubscribeFromLiveCommentaryFeed(
      action.fixtureId,
      action.authorId,
    );
  }
}
