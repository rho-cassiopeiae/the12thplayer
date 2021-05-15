import 'dart:async';

import 'package:flutter/foundation.dart';

import '../enums/live_commentary_feed_vote_action.dart';
import '../enums/live_commentary_filter.dart';
import '../models/vm/fixture_live_commentary_feeds_vm.dart';
import 'live_commentary_feed_states.dart';

abstract class LiveCommentaryFeedAction {}

abstract class LiveCommentaryFeedActionFutureState<
    TState extends LiveCommentaryFeedState> extends LiveCommentaryFeedAction {
  final Completer<TState> _stateReady = Completer<TState>();
  Future<TState> get state => _stateReady.future;

  void complete(TState state) => _stateReady.complete(state);
}

class LoadLiveCommentaryFeeds extends LiveCommentaryFeedAction {
  final int fixtureId;
  final LiveCommentaryFilter filter;
  final int start;

  LoadLiveCommentaryFeeds({
    @required this.fixtureId,
    @required this.filter,
    @required this.start,
  });
}

class VoteForLiveCommentaryFeed extends LiveCommentaryFeedAction {
  final int fixtureId;
  final int authorId;
  final LiveCommentaryFeedVoteAction voteAction;
  final FixtureLiveCommentaryFeedsVm fixtureLiveCommentaryFeeds;

  VoteForLiveCommentaryFeed({
    @required this.fixtureId,
    @required this.authorId,
    @required this.voteAction,
    @required this.fixtureLiveCommentaryFeeds,
  });
}

class LoadLiveCommentaryFeed
    extends LiveCommentaryFeedActionFutureState<LoadLiveCommentaryFeedState> {
  final int fixtureId;
  final int authorId;

  LoadLiveCommentaryFeed({
    @required this.fixtureId,
    @required this.authorId,
  });
}

class SubscribeToLiveCommentaryFeed extends LiveCommentaryFeedAction {
  final int fixtureId;
  final int authorId;
  final String lastReceivedEntryId;

  SubscribeToLiveCommentaryFeed({
    @required this.fixtureId,
    @required this.authorId,
    @required this.lastReceivedEntryId,
  });
}

class UnsubscribeFromLiveCommentaryFeed extends LiveCommentaryFeedAction {
  final int fixtureId;
  final int authorId;

  UnsubscribeFromLiveCommentaryFeed({
    @required this.fixtureId,
    @required this.authorId,
  });
}
