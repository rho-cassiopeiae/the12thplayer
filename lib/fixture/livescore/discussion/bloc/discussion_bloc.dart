import 'dart:async';

import '../../../../general/bloc/bloc.dart';
import 'discussion_states.dart';
import '../services/discussion_service.dart';
import 'discussion_actions.dart';

class DiscussionBloc extends Bloc<DiscussionAction> {
  final DiscussionService _discussionService;

  StreamController<DiscussionState> _stateChannel =
      StreamController<DiscussionState>.broadcast();
  Stream<DiscussionState> get state$ => _stateChannel.stream;

  DiscussionBloc(this._discussionService) {
    actionChannel.stream.listen((action) {
      if (action is LoadDiscussion) {
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
    _stateChannel.close();
    _stateChannel = null;

    if (cleanupAction != null) {
      dispatchAction(cleanupAction);
    } else {
      actionChannel.close();
      actionChannel = null;
    }
  }

  void _loadDiscussion(LoadDiscussion action) async {
    await for (var update in _discussionService.loadDiscussion(
      action.fixtureId,
      action.discussionIdentifier,
    )) {
      var state = update.fold(
        (error) => DiscussionError(message: error.toString()),
        (entries) => DiscussionReady(entries: entries),
      );

      _stateChannel?.add(state);
    }
  }

  void _loadMoreDiscussionEntries(LoadMoreDiscussionEntries action) async {
    var result = await _discussionService.loadMoreDiscussionEntries(
      action.fixtureId,
      action.discussionIdentifier,
      action.lastReceivedEntryId,
    );

    var state = result.fold(
      (error) => DiscussionError(message: error.toString()),
      (entries) => DiscussionReady(entries: entries),
    );

    action.complete(state);
    _stateChannel?.add(state);
  }

  void _unsubscribeFromDiscussion(UnsubscribeFromDiscussion action) {
    _discussionService.unsubscribeFromDiscussion(
      action.fixtureId,
      action.discussionIdentifier,
    );
  }

  void _postDiscussionEntry(PostDiscussionEntry action) async {
    // @@TODO: Validation.
    var result = await _discussionService.postDiscussionEntry(
      action.fixtureId,
      action.discussionIdentifier,
      action.body,
    );

    var error = result.getOrElse(null);
    if (error != null) {
      action.complete(PostDiscussionEntryError(message: error.toString()));
    } else {
      action.complete(PostDiscussionEntryReady());
    }
  }
}
