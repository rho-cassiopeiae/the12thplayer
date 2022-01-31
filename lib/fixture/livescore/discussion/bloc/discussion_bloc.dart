import 'dart:async';

import '../../../../general/bloc/bloc.dart';
import '../services/discussion_service.dart';
import 'discussion_actions.dart';
import 'discussion_states.dart';

class DiscussionBloc extends Bloc<DiscussionAction> {
  final DiscussionService _discussionService;

  StreamController<LoadDiscussionsState> _discussionsStateChannel =
      StreamController<LoadDiscussionsState>.broadcast();
  Stream<LoadDiscussionsState> get discussionsState$ =>
      _discussionsStateChannel.stream;

  StreamController<LoadDiscussionState> _discussionStateChannel =
      StreamController<LoadDiscussionState>.broadcast();
  Stream<LoadDiscussionState> get discussionState$ =>
      _discussionStateChannel.stream;

  DiscussionBloc(this._discussionService) {
    actionChannel.stream.listen((action) {
      if (action is LoadDiscussions) {
        _loadDiscussions(action);
      } else if (action is LoadDiscussion) {
        _loadDiscussion(action);
      } else if (action is LoadMoreDiscussionEntries) {
        _loadMoreDiscussionEntries(action);
      } else if (action is UnsubscribeFromDiscussion) {
        _unsubscribeFromDiscussion(action);
        actionChannel.close();
        actionChannel = null;
      } else if (action is PostDiscussionEntry) {
        _postDiscussionEntry(action);
      }
    });
  }

  @override
  void dispose({DiscussionAction cleanupAction}) {
    _discussionsStateChannel.close();
    _discussionsStateChannel = null;
    _discussionStateChannel.close();
    _discussionStateChannel = null;

    if (cleanupAction != null) {
      dispatchAction(cleanupAction);
    } else {
      actionChannel.close();
      actionChannel = null;
    }
  }

  void _loadDiscussions(LoadDiscussions action) async {
    var result = await _discussionService.loadDiscussions(action.fixtureId);

    var state = result.fold(
      (error) => DiscussionsError(),
      (fixtureDiscussions) => DiscussionsReady(
        fixtureDiscussions: fixtureDiscussions,
      ),
    );

    _discussionsStateChannel?.add(state);
  }

  void _loadDiscussion(LoadDiscussion action) async {
    await for (var update in _discussionService.loadDiscussion(
      action.fixtureId,
      action.discussionId,
    )) {
      var state = update.fold(
        (error) => DiscussionError(),
        (entries) => DiscussionReady(entries: entries),
      );

      _discussionStateChannel?.add(state);
    }
  }

  void _loadMoreDiscussionEntries(LoadMoreDiscussionEntries action) async {
    var entries = await _discussionService.loadMoreDiscussionEntries(
      action.fixtureId,
      action.discussionId,
      action.lastReceivedEntryId,
    );

    var state = DiscussionReady(entries: entries);

    action.complete(state);
    _discussionStateChannel?.add(state);
  }

  void _unsubscribeFromDiscussion(UnsubscribeFromDiscussion action) {
    _discussionService.unsubscribeFromDiscussion(
      action.fixtureId,
      action.discussionId,
    );
  }

  void _postDiscussionEntry(PostDiscussionEntry action) async {
    // @@TODO: Validation.
    var result = await _discussionService.postDiscussionEntry(
      action.fixtureId,
      action.discussionId,
      action.body,
    );

    var state = result.fold(
      () => DiscussionEntryPostingSucceeded(),
      (error) => DiscussionEntryPostingFailed(),
    );

    action.complete(state);
  }
}
