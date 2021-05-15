import 'dart:async';

import 'live_commentary_recording_states.dart';
import '../services/live_commentary_recording_service.dart';
import '../../../../general/bloc/bloc.dart';
import 'live_commentary_recording_actions.dart';

class LiveCommentaryRecordingBloc extends Bloc<LiveCommentaryRecordingAction> {
  final LiveCommentaryRecordingService _liveCommentaryRecordingService;

  StreamController<LiveCommentaryRecordingNameState> _nameStateChannel =
      StreamController<LiveCommentaryRecordingNameState>.broadcast();
  Stream<LiveCommentaryRecordingNameState> get nameState$ =>
      _nameStateChannel.stream;

  StreamController<LiveCommentaryRecordingPublishButtonState>
      _publishButtonStateChannel =
      StreamController<LiveCommentaryRecordingPublishButtonState>.broadcast();
  Stream<LiveCommentaryRecordingPublishButtonState> get publishButtonState$ =>
      _publishButtonStateChannel.stream;

  StreamController<LiveCommentaryRecordingEntriesState> _entriesStateChannel =
      StreamController<LiveCommentaryRecordingEntriesState>.broadcast();
  Stream<LiveCommentaryRecordingEntriesState> get entriesState$ =>
      _entriesStateChannel.stream;

  LiveCommentaryRecordingBloc(this._liveCommentaryRecordingService) {
    actionChannel.stream.listen((action) {
      if (action is LoadLiveCommentaryRecording) {
        _loadLiveCommentaryRecording(action);
      } else if (action is ToggleLiveCommentaryRecordingPublishMode) {
        _toggleLiveCommentaryRecordingPublishMode(action);
      } else if (action is PostLiveCommentaryRecordingEntry) {
        _postLiveCommentaryRecordingEntry(action);
      } else if (action is RenameLiveCommentaryRecording) {
        _renameLiveCommentaryRecording(action);
      }
    });
  }

  @override
  void dispose({LiveCommentaryRecordingAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _nameStateChannel.close();
    _nameStateChannel = null;
    _publishButtonStateChannel.close();
    _publishButtonStateChannel = null;
    _entriesStateChannel.close();
    _entriesStateChannel = null;
  }

  void _loadLiveCommentaryRecording(LoadLiveCommentaryRecording action) async {
    var result = await _liveCommentaryRecordingService
        .loadLiveCommentaryRecording(action.fixtureId);

    var state = result.fold(
      (error) => LiveCommentaryRecordingError(message: error.toString()),
      (recording) => LiveCommentaryRecordingReady(recording: recording),
    );

    if (state is LiveCommentaryRecordingError) {
      _entriesStateChannel?.add(
        LiveCommentaryRecordingEntriesError(message: state.message),
      );
      _nameStateChannel?.add(LiveCommentaryRecordingNameError());
    } else if (state is LiveCommentaryRecordingReady) {
      var recording = state.recording;

      _entriesStateChannel?.add(
        LiveCommentaryRecordingEntriesReady(entries: recording.entries),
      );
      _publishButtonStateChannel?.add(
        recording.isInPublishMode
            ? LiveCommentaryRecordingPublishButtonActive()
            : LiveCommentaryRecordingPublishButtonInactive(),
      );
      _nameStateChannel?.add(
        LiveCommentaryRecordingNameReady(
          name: recording.name,
          creationStatus: recording.creationStatus,
        ),
      );
    }
  }

  void _toggleLiveCommentaryRecordingPublishMode(
    ToggleLiveCommentaryRecordingPublishMode action,
  ) async {
    await for (var result in _liveCommentaryRecordingService
        .toggleLiveCommentaryRecordingPublishMode(
      action.fixtureId,
    )) {
      var state = result.fold(
        (error) => LiveCommentaryRecordingError(message: error.toString()),
        (recording) => LiveCommentaryRecordingReady(recording: recording),
      );

      if (state is LiveCommentaryRecordingError) {
        // @@TODO: Handle error.
      } else if (state is LiveCommentaryRecordingReady) {
        var recording = state.recording;

        if (recording.isInPublishMode != null) {
          _publishButtonStateChannel?.add(
            recording.isInPublishMode
                ? LiveCommentaryRecordingPublishButtonActive()
                : LiveCommentaryRecordingPublishButtonInactive(),
          );
        } else if (recording.creationStatus != null) {
          _nameStateChannel?.add(
            LiveCommentaryRecordingNameReady(
              name: recording.name,
              creationStatus: recording.creationStatus,
            ),
          );
        } else if (recording.entries != null) {
          _entriesStateChannel?.add(
            LiveCommentaryRecordingEntriesReady(entries: recording.entries),
          );
        }
      }
    }
  }

  void _renameLiveCommentaryRecording(
    RenameLiveCommentaryRecording action,
  ) async {
    // @@TODO: Validation.
    var result =
        await _liveCommentaryRecordingService.renameLiveCommentaryRecording(
      action.fixtureId,
      action.name,
    );

    var error = result.getOrElse(null);
    if (error != null) {
      action.complete(
        RenameLiveCommentaryRecordingError(message: error.toString()),
      );
    } else {
      action.complete(RenameLiveCommentaryRecordingReady());
    }
  }

  void _postLiveCommentaryRecordingEntry(
    PostLiveCommentaryRecordingEntry action,
  ) async {
    // @@TODO: Validation.
    var valid = true;
    if (!valid) {
      action.complete(
        PostLiveCommentaryRecordingEntryError(message: 'Not valid'),
      );
      return;
    } else {
      action.complete(PostLiveCommentaryRecordingEntryInProgress());
    }

    await for (var result
        in _liveCommentaryRecordingService.postLiveCommentaryRecordingEntry(
      action.fixtureId,
      action.time,
      action.icon,
      action.title,
      action.body,
      action.imageBytes,
    )) {
      var state = result.fold(
        (error) => LiveCommentaryRecordingError(message: error.toString()),
        (recording) => LiveCommentaryRecordingReady(recording: recording),
      );

      if (state is LiveCommentaryRecordingError) {
        _entriesStateChannel?.add(
          LiveCommentaryRecordingEntriesError(message: state.message),
        );
        _nameStateChannel?.add(LiveCommentaryRecordingNameError());
      } else if (state is LiveCommentaryRecordingReady) {
        var recording = state.recording;

        if (recording.creationStatus != null) {
          _nameStateChannel?.add(
            LiveCommentaryRecordingNameReady(
              name: recording.name,
              creationStatus: recording.creationStatus,
            ),
          );
        } else if (recording.entries != null) {
          _entriesStateChannel?.add(
            LiveCommentaryRecordingEntriesReady(entries: recording.entries),
          );
        }
      }
    }
  }
}
