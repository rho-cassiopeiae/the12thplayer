import '../entities/live_commentary_recording_entry_entity.dart';

class LiveCommentaryRecordingEntryDto {
  final String time;
  final String icon;
  final String title;
  final String body;
  final String imageUrl;

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['time'] = time;
    map['icon'] = icon;
    map['title'] = title;
    map['body'] = body;
    map['imageUrl'] = imageUrl;

    return map;
  }

  LiveCommentaryRecordingEntryDto.fromEntity(
    LiveCommentaryRecordingEntryEntity entry,
  )   : time = entry.time,
        icon = entry.icon,
        title = entry.title,
        body = entry.body,
        imageUrl = entry.imageUrl;
}
