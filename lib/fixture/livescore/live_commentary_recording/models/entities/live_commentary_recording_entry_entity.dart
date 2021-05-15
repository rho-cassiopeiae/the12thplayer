import 'package:flutter/foundation.dart';

import '../../enums/live_commentary_recording_entry_status.dart';
import '../../persistence/tables/live_commentary_recording_entry_table.dart';

class LiveCommentaryRecordingEntryEntity {
  final int fixtureId;
  final int teamId;
  final int postedAt;
  final String time;
  final String icon;
  final String title;
  final String body;
  final String imagePath;
  final String imageUrl;
  final LiveCommentaryRecordingEntryStatus status;

  LiveCommentaryRecordingEntryEntity({
    @required this.fixtureId,
    @required this.teamId,
    @required this.postedAt,
    @required this.time,
    @required this.icon,
    @required this.title,
    @required this.body,
    @required this.imagePath,
    @required this.imageUrl,
    @required this.status,
  });

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[LiveCommentaryRecordingEntryTable.fixtureId] = fixtureId;
    map[LiveCommentaryRecordingEntryTable.teamId] = teamId;
    map[LiveCommentaryRecordingEntryTable.postedAt] = postedAt;
    map[LiveCommentaryRecordingEntryTable.time] = time;
    map[LiveCommentaryRecordingEntryTable.icon] = icon;
    map[LiveCommentaryRecordingEntryTable.title] = title;
    map[LiveCommentaryRecordingEntryTable.body] = body;
    map[LiveCommentaryRecordingEntryTable.imagePath] = imagePath;
    map[LiveCommentaryRecordingEntryTable.imageUrl] = imageUrl;
    map[LiveCommentaryRecordingEntryTable.status] = status.index;

    return map;
  }

  LiveCommentaryRecordingEntryEntity.fromMap(Map<String, dynamic> map)
      : fixtureId = map[LiveCommentaryRecordingEntryTable.fixtureId],
        teamId = map[LiveCommentaryRecordingEntryTable.teamId],
        postedAt = map[LiveCommentaryRecordingEntryTable.postedAt],
        time = map[LiveCommentaryRecordingEntryTable.time],
        icon = map[LiveCommentaryRecordingEntryTable.icon],
        title = map[LiveCommentaryRecordingEntryTable.title],
        body = map[LiveCommentaryRecordingEntryTable.body],
        imagePath = map[LiveCommentaryRecordingEntryTable.imagePath],
        imageUrl = null,
        status = LiveCommentaryRecordingEntryStatus
            .values[map[LiveCommentaryRecordingEntryTable.status]];

  LiveCommentaryRecordingEntryEntity copyWith({
    String imageUrl,
    LiveCommentaryRecordingEntryStatus status,
  }) {
    return LiveCommentaryRecordingEntryEntity(
      fixtureId: fixtureId,
      teamId: teamId,
      postedAt: postedAt,
      time: time,
      icon: icon,
      title: title,
      body: body,
      imagePath: imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
    );
  }
}
