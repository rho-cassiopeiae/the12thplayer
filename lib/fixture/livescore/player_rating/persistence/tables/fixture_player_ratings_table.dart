class FixturePlayerRatingsTable {
  static const tableName = 'FixturePlayerRatings';

  static const fixtureId = 'FixtureId';
  static const teamId = 'TeamId';
  static const finalized = 'Finalized';
  static const playerRatings = 'PlayerRatings';

  static final createTableCommand = '''
    CREATE TABLE $tableName (
      $fixtureId INTEGER NOT NULL,
      $teamId INTEGER NOT NULL,
      $finalized INTEGER NOT NULL,
      $playerRatings TEXT NOT NULL,
      PRIMARY KEY ($fixtureId, $teamId)
    );
  ''';
}
