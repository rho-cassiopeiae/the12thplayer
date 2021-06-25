import 'dart:async';

import 'package:flutter/foundation.dart';

import 'discussion_states.dart';

abstract class DiscussionAction {}

abstract class DiscussionActionFutureState<TState extends DiscussionState>
    extends DiscussionAction {
  final Completer<TState> _stateReady = Completer<TState>();
  Future<TState> get state => _stateReady.future;

  void complete(TState state) => _stateReady.complete(state);
}

class LoadDiscussions extends DiscussionAction {
  final int fixtureId;

  LoadDiscussions({@required this.fixtureId});
}

class LoadDiscussion extends DiscussionAction {
  final int fixtureId;
  final String discussionIdentifier;

  LoadDiscussion({
    @required this.fixtureId,
    @required this.discussionIdentifier,
  });
}

class LoadMoreDiscussionEntries
    extends DiscussionActionFutureState<LoadDiscussionState> {
  final int fixtureId;
  final String discussionIdentifier;
  final String lastReceivedEntryId;

  LoadMoreDiscussionEntries({
    @required this.fixtureId,
    @required this.discussionIdentifier,
    @required this.lastReceivedEntryId,
  });
}

class UnsubscribeFromDiscussion extends DiscussionAction {
  final int fixtureId;
  final String discussionIdentifier;

  UnsubscribeFromDiscussion({
    @required this.fixtureId,
    @required this.discussionIdentifier,
  });
}

class PostDiscussionEntry
    extends DiscussionActionFutureState<PostDiscussionEntryState> {
  final int fixtureId;
  final String discussionIdentifier;
  final String body;

  PostDiscussionEntry({
    @required this.fixtureId,
    @required this.discussionIdentifier,
    @required this.body,
  });
}
