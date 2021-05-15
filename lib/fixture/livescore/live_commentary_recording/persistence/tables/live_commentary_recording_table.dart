class LiveCommentaryRecordingTable {
  static const tableName = 'LiveCommentaryRecording';

  static const fixtureId = 'FixtureId';
  static const teamId = 'TeamId';
  static const name = 'Name';
  static const creationStatus = 'CreationStatus';

  static final createTableCommand = '''
    CREATE TABLE $tableName (
      $fixtureId INTEGER NOT NULL,
      $teamId INTEGER NOT NULL,
      $name TEXT NOT NULL,
      $creationStatus INTEGER NOT NULL,
      PRIMARY KEY ($fixtureId, $teamId)
    );
  ''';
}
