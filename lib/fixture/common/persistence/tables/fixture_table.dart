class FixtureTable {
  static const tableName = 'Fixture';

  static const id = 'Id';
  static const teamId = 'TeamId';
  static const leagueName = 'LeagueName';
  static const leagueLogoUrl = 'LeagueLogoUrl';
  static const opponentTeamId = 'OpponentTeamId';
  static const opponentTeamName = 'OpponentTeamName';
  static const opponentTeamLogoUrl = 'OpponentTeamLogoUrl';
  static const homeStatus = 'HomeStatus';
  static const startTime = 'StartTime';
  static const status = 'Status';
  static const gameTime = 'GameTime';
  static const score = 'Score';
  static const venueName = 'VenueName';
  static const venueImageUrl = 'VenueImageUrl';
  static const refereeName = 'RefereeName';
  static const colors = 'Colors';
  static const lineups = 'Lineups';
  static const events = 'Events';
  static const stats = 'Stats';
  static const isFullyLoaded = 'IsFullyLoaded';

  static final createTableCommand = '''
    CREATE TABLE $tableName (
      $id INTEGER NOT NULL,
      $teamId INTEGER NOT NULL,
      $leagueName TEXT,
      $leagueLogoUrl TEXT,
      $opponentTeamId INTEGER NOT NULL,
      $opponentTeamName TEXT NOT NULL,
      $opponentTeamLogoUrl TEXT NOT NULL,
      $homeStatus INTEGER NOT NULL,
      $startTime INTEGER,
      $status TEXT NOT NULL,
      $gameTime TEXT NOT NULL,
      $score TEXT NOT NULL,
      $venueName TEXT,
      $venueImageUrl TEXT,
      $refereeName TEXT,
      $colors TEXT,
      $lineups TEXT,
      $events TEXT,
      $stats TEXT,
      $isFullyLoaded INTEGER NOT NULL,
      PRIMARY KEY ($id, $teamId)
    );
  ''';
}
