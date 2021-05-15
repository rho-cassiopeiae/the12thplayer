import '../models/dto/live_commentary_recording_entry_dto.dart';

abstract class ILiveCommentaryRecordingApiService {
  Future createLiveCommentaryRecording(
    int fixtureId,
    int teamId,
    String name,
  );

  Future postLiveCommentaryRecordingEntry(
    int fixtureId,
    int teamId,
    LiveCommentaryRecordingEntryDto entry,
  );

  Future postLiveCommentaryRecordingEntries(
    int fixtureId,
    int teamId,
    Iterable<LiveCommentaryRecordingEntryDto> entries,
  );

  Future<String> uploadLiveCommentaryRecordingEntryImage(
    int fixtureId,
    int teamId,
    String imagePath,
  );
}
