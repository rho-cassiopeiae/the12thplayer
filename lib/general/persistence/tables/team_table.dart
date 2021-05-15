class TeamTable {
  static const tableName = 'Team';

  static const id = 'Id';
  static const name = 'Name';
  static const logoUrl = 'LogoUrl';
  static const currentlySelected = 'CurrentlySelected';

  static final createTableCommand = '''
    CREATE TABLE $tableName (
      $id INTEGER PRIMARY KEY,
      $name TEXT NOT NULL,
      $logoUrl TEXT NOT NULL,
      $currentlySelected INTEGER NOT NULL
    );
  ''';
}
