import 'package:flutter/foundation.dart';

import '../live_commentary_recording_entry_dto.dart';

class PostLiveCommentaryRecordingEntriesRequestDto {
  final int fixtureId;
  final int teamId;
  final Iterable<LiveCommentaryRecordingEntryDto> entries;

  PostLiveCommentaryRecordingEntriesRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.entries,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['entries'] = entries.map((entry) => entry.toJson()).toList();

    return map;
  }
}
