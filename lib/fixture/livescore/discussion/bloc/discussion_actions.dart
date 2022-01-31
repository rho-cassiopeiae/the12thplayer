import 'package:flutter/foundation.dart';

import '../../../../general/bloc/mixins.dart';
import 'discussion_states.dart';

abstract class DiscussionAction {}

abstract class DiscussionActionAwaitable<T extends DiscussionState>
    extends DiscussionAction with AwaitableState<T> {}

class LoadDiscussions extends DiscussionAction {
  final int fixtureId;

  LoadDiscussions({@required this.fixtureId});
}

class LoadDiscussion extends DiscussionAction {
  final int fixtureId;
  final String discussionId;

  LoadDiscussion({
    @required this.fixtureId,
    @required this.discussionId,
  });
}

class LoadMoreDiscussionEntries
    extends DiscussionActionAwaitable<DiscussionReady> {
  final int fixtureId;
  final String discussionId;
  final String lastReceivedEntryId;

  LoadMoreDiscussionEntries({
    @required this.fixtureId,
    @required this.discussionId,
    @required this.lastReceivedEntryId,
  });
}

class UnsubscribeFromDiscussion extends DiscussionAction {
  final int fixtureId;
  final String discussionId;

  UnsubscribeFromDiscussion({
    @required this.fixtureId,
    @required this.discussionId,
  });
}

class PostDiscussionEntry
    extends DiscussionActionAwaitable<PostDiscussionEntryState> {
  final int fixtureId;
  final String discussionId;
  final String body;

  PostDiscussionEntry({
    @required this.fixtureId,
    @required this.discussionId,
    @required this.body,
  });
}
