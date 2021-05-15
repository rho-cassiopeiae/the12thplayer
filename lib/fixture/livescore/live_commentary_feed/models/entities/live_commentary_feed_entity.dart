import 'package:flutter/foundation.dart';

import '../dto/fixture_live_commentary_feed_update_dto.dart';
import 'live_commentary_feed_entry_entity.dart';
import '../../persistence/tables/live_commentary_feed_table.dart';

class LiveCommentaryFeedEntity {
  final int fixtureId;
  final int teamId;
  final int authorId;

  Iterable<LiveCommentaryFeedEntryEntity> _entries;
  Iterable<LiveCommentaryFeedEntryEntity> get entries => _entries;

  LiveCommentaryFeedEntity.noEntries({
    @required this.fixtureId,
    @required this.teamId,
    @required this.authorId,
  }) {
    _entries = [];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[LiveCommentaryFeedTable.fixtureId] = fixtureId;
    map[LiveCommentaryFeedTable.teamId] = teamId;
    map[LiveCommentaryFeedTable.authorId] = authorId;

    return map;
  }

  LiveCommentaryFeedEntity.fromMap(
    Map<String, dynamic> map,
    Iterable<LiveCommentaryFeedEntryEntity> entries,
  )   : fixtureId = map[LiveCommentaryFeedTable.fixtureId],
        teamId = map[LiveCommentaryFeedTable.teamId],
        authorId = map[LiveCommentaryFeedTable.authorId],
        _entries = entries;

  LiveCommentaryFeedEntity.fromUpdateDto(
    FixtureLiveCommentaryFeedUpdateDto fixtureLiveCommFeedUpdate,
  )   : fixtureId = fixtureLiveCommFeedUpdate.fixtureId,
        teamId = fixtureLiveCommFeedUpdate.teamId,
        authorId = fixtureLiveCommFeedUpdate.authorId,
        _entries = fixtureLiveCommFeedUpdate.entries.map(
          (entry) => LiveCommentaryFeedEntryEntity.fromDto(
            fixtureLiveCommFeedUpdate,
            entry,
          ),
        );
}
