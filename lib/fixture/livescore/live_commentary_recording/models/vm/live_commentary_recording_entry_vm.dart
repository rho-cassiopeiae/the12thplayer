import '../../enums/live_commentary_recording_entry_status.dart';
import '../entities/live_commentary_recording_entry_entity.dart';

class LiveCommentaryRecordingEntryVm {
  final int postedAt;
  final String time;
  final String icon;
  final String title;
  final String body;
  final String imagePath;
  final LiveCommentaryRecordingEntryStatus status;

  LiveCommentaryRecordingEntryVm.fromEntity(
    LiveCommentaryRecordingEntryEntity entry,
  )   : postedAt = entry.postedAt,
        time = entry.time,
        icon = entry.icon,
        title = entry.title,
        body = entry.body,
        imagePath = entry.imagePath,
        status = entry.status;
}
