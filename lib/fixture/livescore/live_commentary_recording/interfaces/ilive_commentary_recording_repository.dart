import '../enums/live_commentary_recording_entry_status.dart';
import '../enums/live_commentary_recording_status.dart';
import '../models/entities/live_commentary_recording_entry_entity.dart';
import '../models/entities/live_commentary_recording_entity.dart';

abstract class ILiveCommentaryRecordingRepository {
  Future<LiveCommentaryRecordingEntity> loadLiveCommentaryRecordingOfFixture(
    int fixtureId,
    int teamId,
  );

  Future renameLiveCommentaryRecordingOfFixture(
    int fixtureId,
    int teamId,
    String name,
  );

  Future<LiveCommentaryRecordingEntity>
      loadLiveCommentaryRecordingNameAndStatus(
    int fixtureId,
    int teamId,
  );

  Future updateLiveCommentaryRecordingStatus(
    int fixtureId,
    int teamId,
    LiveCommentaryRecordingStatus status,
  );

  Future addLiveCommentaryRecordingEntry(
    LiveCommentaryRecordingEntryEntity entry,
  );

  Future<Iterable<LiveCommentaryRecordingEntryEntity>>
      loadLiveCommentaryRecordingEntries(
    int fixtureId,
    int teamId,
  );

  Future updateLiveCommentaryRecordingEntry(
    LiveCommentaryRecordingEntryEntity entry,
  );

  Future<LiveCommentaryRecordingEntryStatus>
      loadPrevLiveCommentaryRecordingEntryStatus(
    int fixtureId,
    int teamId,
    int currentEntryPostedAt,
  );

  Future<Iterable<LiveCommentaryRecordingEntryEntity>>
      loadNotPublishedLiveCommentaryRecordingEntries(
    int fixtureId,
    int teamId,
  );

  Future updateLiveCommentaryRecordingEntries(
    Iterable<LiveCommentaryRecordingEntryEntity> entries,
  );
}
