import 'package:flutter/foundation.dart';

import '../../enums/live_commentary_recording_status.dart';
import 'live_commentary_recording_entry_entity.dart';
import '../../persistence/tables/live_commentary_recording_table.dart';
import '../../../../../general/extensions/map_extension.dart';

class LiveCommentaryRecordingEntity {
  final int fixtureId;
  final int teamId;
  final String name;
  final LiveCommentaryRecordingStatus creationStatus;

  Iterable<LiveCommentaryRecordingEntryEntity> _entries;
  Iterable<LiveCommentaryRecordingEntryEntity> get entries => _entries;

  LiveCommentaryRecordingEntity.noEntries({
    @required this.fixtureId,
    @required this.teamId,
    @required this.name,
    @required this.creationStatus,
  }) {
    _entries = [];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[LiveCommentaryRecordingTable.fixtureId] = fixtureId;
    map[LiveCommentaryRecordingTable.teamId] = teamId;
    map[LiveCommentaryRecordingTable.name] = name;
    map[LiveCommentaryRecordingTable.creationStatus] = creationStatus.index;

    return map;
  }

  LiveCommentaryRecordingEntity.fromMap(
    Map<String, dynamic> map,
    Iterable<LiveCommentaryRecordingEntryEntity> entries,
  )   : fixtureId = map.getOrNull(LiveCommentaryRecordingTable.fixtureId),
        teamId = map.getOrNull(LiveCommentaryRecordingTable.teamId),
        name = map[LiveCommentaryRecordingTable.name],
        creationStatus = LiveCommentaryRecordingStatus
            .values[map[LiveCommentaryRecordingTable.creationStatus]],
        _entries = entries;
}
