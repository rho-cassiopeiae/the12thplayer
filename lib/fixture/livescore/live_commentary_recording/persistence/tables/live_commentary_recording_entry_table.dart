import 'live_commentary_recording_table.dart';

class LiveCommentaryRecordingEntryTable {
  static const tableName = 'LiveCommentaryRecordingEntry';

  static const fixtureId = 'FixtureId';
  static const teamId = 'TeamId';
  static const postedAt = 'PostedAt';
  static const time = 'Time';
  static const icon = 'Icon';
  static const title = 'Title';
  static const body = 'Body';
  static const imagePath = 'ImagePath';
  static const imageUrl = 'ImageUrl';
  static const status = 'Status';

  static final createTableCommand = '''
    CREATE TABLE $tableName (
      $fixtureId INTEGER NOT NULL,
      $teamId INTEGER NOT NULL,
      $postedAt INTEGER NOT NULL,
      $time TEXT,
      $icon TEXT,
      $title TEXT,
      $body TEXT,
      $imagePath TEXT,
      $imageUrl TEXT,
      $status INTEGER NOT NULL,
      PRIMARY KEY ($fixtureId, $teamId, $postedAt),
      FOREIGN KEY ($fixtureId, $teamId)
        REFERENCES ${LiveCommentaryRecordingTable.tableName} (${LiveCommentaryRecordingTable.fixtureId}, ${LiveCommentaryRecordingTable.teamId})
    );
  ''';
}
