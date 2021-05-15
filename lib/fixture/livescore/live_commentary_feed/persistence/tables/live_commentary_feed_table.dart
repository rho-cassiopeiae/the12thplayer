class LiveCommentaryFeedTable {
  static const tableName = 'LiveCommentaryFeed';

  static const fixtureId = 'FixtureId';
  static const teamId = 'TeamId';
  static const authorId = 'AuthorId';

  static final createTableCommand = '''
    CREATE TABLE $tableName (
      $fixtureId INTEGER NOT NULL,
      $teamId INTEGER NOT NULL,
      $authorId INTEGER NOT NULL,
      PRIMARY KEY ($fixtureId, $teamId, $authorId)
    );
  ''';
}
