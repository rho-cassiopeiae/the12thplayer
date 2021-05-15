import '../../enums/live_commentary_recording_status.dart';
import '../entities/live_commentary_recording_entity.dart';
import 'live_commentary_recording_entry_vm.dart';

class LiveCommentaryRecordingVm {
  final String name;
  final bool isInPublishMode;
  final List<LiveCommentaryRecordingEntryVm> entries;
  final LiveCommentaryRecordingStatus creationStatus;

  LiveCommentaryRecordingVm({
    this.name,
    this.isInPublishMode,
    this.entries,
    this.creationStatus,
  });

  LiveCommentaryRecordingVm.fromEntity(
    LiveCommentaryRecordingEntity recording,
    bool isInPublishMode,
  )   : name = recording.name,
        isInPublishMode = isInPublishMode,
        entries = recording.entries
            .map((entry) => LiveCommentaryRecordingEntryVm.fromEntity(entry))
            .toList(),
        creationStatus = recording.creationStatus;
}
