import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'live_commentary_recording_states.dart';

abstract class LiveCommentaryRecordingAction {}

abstract class LiveCommentaryRecordingActionFutureState<
        TState extends LiveCommentaryRecordingState>
    extends LiveCommentaryRecordingAction {
  final Completer<TState> _stateReady = Completer<TState>();
  Future<TState> get state => _stateReady.future;

  void complete(TState state) => _stateReady.complete(state);
}

class LoadLiveCommentaryRecording extends LiveCommentaryRecordingAction {
  final int fixtureId;

  LoadLiveCommentaryRecording({@required this.fixtureId});
}

class RenameLiveCommentaryRecording
    extends LiveCommentaryRecordingActionFutureState<
        RenameLiveCommentaryRecordingState> {
  final int fixtureId;
  final String name;

  RenameLiveCommentaryRecording({
    @required this.fixtureId,
    @required this.name,
  });
}

class ToggleLiveCommentaryRecordingPublishMode
    extends LiveCommentaryRecordingAction {
  final int fixtureId;

  ToggleLiveCommentaryRecordingPublishMode({@required this.fixtureId});
}

class PostLiveCommentaryRecordingEntry
    extends LiveCommentaryRecordingActionFutureState<
        PostLiveCommentaryRecordingEntryState> {
  final int fixtureId;
  final String time;
  final String icon;
  final String title;
  final String body;
  final Uint8List imageBytes;

  PostLiveCommentaryRecordingEntry({
    @required this.fixtureId,
    @required this.time,
    @required this.icon,
    @required this.title,
    @required this.body,
    @required this.imageBytes,
  });
}
