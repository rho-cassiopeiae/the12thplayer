import '../models/entities/live_commentary_feed_entry_entity.dart';
import '../models/entities/live_commentary_feed_entity.dart';

abstract class ILiveCommentaryFeedRepository {
  Future<LiveCommentaryFeedEntity> loadLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
  );

  Future addLiveCommentaryFeedEntries(
    Iterable<LiveCommentaryFeedEntryEntity> entries,
  );
}
