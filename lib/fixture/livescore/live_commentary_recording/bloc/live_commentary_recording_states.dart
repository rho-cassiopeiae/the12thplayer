import 'package:flutter/foundation.dart';

import '../enums/live_commentary_recording_status.dart';
import '../models/vm/live_commentary_recording_entry_vm.dart';
import '../models/vm/live_commentary_recording_vm.dart';

abstract class LiveCommentaryRecordingState {}

abstract class LiveCommentaryRecordingPublishButtonState
    extends LiveCommentaryRecordingState {}

class LiveCommentaryRecordingPublishButtonLoading
    extends LiveCommentaryRecordingPublishButtonState {}

class LiveCommentaryRecordingPublishButtonActive
    extends LiveCommentaryRecordingPublishButtonState {}

class LiveCommentaryRecordingPublishButtonInactive
    extends LiveCommentaryRecordingPublishButtonState {}

abstract class LiveCommentaryRecordingNameState
    extends LiveCommentaryRecordingState {}

class LiveCommentaryRecordingNameLoading
    extends LiveCommentaryRecordingNameState {}

class LiveCommentaryRecordingNameReady
    extends LiveCommentaryRecordingNameState {
  final String name;
  final LiveCommentaryRecordingStatus creationStatus;

  LiveCommentaryRecordingNameReady({
    @required this.name,
    @required this.creationStatus,
  });
}

class LiveCommentaryRecordingNameError
    extends LiveCommentaryRecordingNameState {}

abstract class LiveCommentaryRecordingEntriesState
    extends LiveCommentaryRecordingState {}

class LiveCommentaryRecordingEntriesLoading
    extends LiveCommentaryRecordingEntriesState {}

class LiveCommentaryRecordingEntriesReady
    extends LiveCommentaryRecordingEntriesState {
  final List<LiveCommentaryRecordingEntryVm> entries;

  LiveCommentaryRecordingEntriesReady({@required this.entries});
}

class LiveCommentaryRecordingEntriesError
    extends LiveCommentaryRecordingEntriesState {
  final String message;

  LiveCommentaryRecordingEntriesError({@required this.message});
}

class LiveCommentaryRecordingReady extends LiveCommentaryRecordingState {
  final LiveCommentaryRecordingVm recording;

  LiveCommentaryRecordingReady({@required this.recording});
}

class LiveCommentaryRecordingError extends LiveCommentaryRecordingState {
  final String message;

  LiveCommentaryRecordingError({@required this.message});
}

abstract class RenameLiveCommentaryRecordingState
    extends LiveCommentaryRecordingState {}

class RenameLiveCommentaryRecordingReady
    extends RenameLiveCommentaryRecordingState {}

class RenameLiveCommentaryRecordingError
    extends RenameLiveCommentaryRecordingState {
  final String message;

  RenameLiveCommentaryRecordingError({@required this.message});
}

abstract class PostLiveCommentaryRecordingEntryState
    extends LiveCommentaryRecordingState {}

class PostLiveCommentaryRecordingEntryInProgress
    extends PostLiveCommentaryRecordingEntryState {}

class PostLiveCommentaryRecordingEntryError
    extends PostLiveCommentaryRecordingEntryState {
  final String message;

  PostLiveCommentaryRecordingEntryError({@required this.message});
}
