class FixturePerformanceRatingsTable {
  static const tableName = 'FixturePerformanceRatings';

  static const fixtureId = 'FixtureId';
  static const teamId = 'TeamId';
  static const isFinalized = 'IsFinalized';
  static const performanceRatings = 'PerformanceRatings';

  static final createTableCommand = '''
    CREATE TABLE $tableName (
      $fixtureId INTEGER NOT NULL,
      $teamId INTEGER NOT NULL,
      $isFinalized INTEGER NOT NULL,
      $performanceRatings TEXT,
      PRIMARY KEY ($fixtureId, $teamId)
    );
  ''';
}
