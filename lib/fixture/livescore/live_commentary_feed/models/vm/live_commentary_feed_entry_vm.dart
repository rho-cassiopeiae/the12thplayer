import '../entities/live_commentary_feed_entry_entity.dart';

class LiveCommentaryFeedEntryVm {
  final String id;
  final String time;
  final String icon;
  final String title;
  final String body;
  final String imageUrl;

  LiveCommentaryFeedEntryVm.fromEntity(LiveCommentaryFeedEntryEntity entry)
      : id = '${entry.idTime}-${entry.idSeq}',
        time = entry.time,
        icon = entry.icon,
        title = entry.title,
        body = entry.body,
        imageUrl = entry.imageUrl;
}
