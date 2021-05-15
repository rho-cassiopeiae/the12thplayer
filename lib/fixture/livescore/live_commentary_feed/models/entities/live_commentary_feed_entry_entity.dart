import '../dto/fixture_live_commentary_feed_update_dto.dart';
import '../dto/live_commentary_feed_entry_dto.dart';
import '../../persistence/tables/live_commentary_feed_entry_table.dart';

class LiveCommentaryFeedEntryEntity {
  final int fixtureId;
  final int teamId;
  final int authorId;
  final int idTime;
  final int idSeq;
  final String time;
  final String icon;
  final String title;
  final String body;
  final String imageUrl;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[LiveCommentaryFeedEntryTable.fixtureId] = fixtureId;
    map[LiveCommentaryFeedEntryTable.teamId] = teamId;
    map[LiveCommentaryFeedEntryTable.authorId] = authorId;
    map[LiveCommentaryFeedEntryTable.idTime] = idTime;
    map[LiveCommentaryFeedEntryTable.idSeq] = idSeq;
    map[LiveCommentaryFeedEntryTable.time] = time;
    map[LiveCommentaryFeedEntryTable.icon] = icon;
    map[LiveCommentaryFeedEntryTable.title] = title;
    map[LiveCommentaryFeedEntryTable.body] = body;
    map[LiveCommentaryFeedEntryTable.imageUrl] = imageUrl;

    return map;
  }

  LiveCommentaryFeedEntryEntity.fromMap(Map<String, dynamic> map)
      : fixtureId = map[LiveCommentaryFeedEntryTable.fixtureId],
        teamId = map[LiveCommentaryFeedEntryTable.teamId],
        authorId = map[LiveCommentaryFeedEntryTable.authorId],
        idTime = map[LiveCommentaryFeedEntryTable.idTime],
        idSeq = map[LiveCommentaryFeedEntryTable.idSeq],
        time = map[LiveCommentaryFeedEntryTable.time],
        icon = map[LiveCommentaryFeedEntryTable.icon],
        title = map[LiveCommentaryFeedEntryTable.title],
        body = map[LiveCommentaryFeedEntryTable.body],
        imageUrl = map[LiveCommentaryFeedEntryTable.imageUrl];

  LiveCommentaryFeedEntryEntity.fromDto(
    FixtureLiveCommentaryFeedUpdateDto fixtureLiveCommFeedUpdate,
    LiveCommentaryFeedEntryDto entry,
  )   : fixtureId = fixtureLiveCommFeedUpdate.fixtureId,
        teamId = fixtureLiveCommFeedUpdate.teamId,
        authorId = fixtureLiveCommFeedUpdate.authorId,
        idTime = int.parse(entry.id.split('-')[0]),
        idSeq = int.parse(entry.id.split('-')[1]),
        time = entry.time,
        icon = entry.icon,
        title = entry.title,
        body = entry.body,
        imageUrl = entry.imageUrl;
}
