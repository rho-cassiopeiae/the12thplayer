import 'package:flutter/foundation.dart';

import '../live_commentary_recording_entry_dto.dart';

class PostLiveCommentaryRecordingEntryRequestDto {
  final int fixtureId;
  final int teamId;
  final LiveCommentaryRecordingEntryDto entry;

  PostLiveCommentaryRecordingEntryRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.entry,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['entry'] = entry.toJson();

    return map;
  }
}
