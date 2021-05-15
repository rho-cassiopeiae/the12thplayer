class AccountTable {
  static const tableName = 'Account';

  static const email = 'Email';
  static const username = 'Username';
  static const accessToken = 'AccessToken';
  static const refreshToken = 'RefreshToken';
  static const type = 'Type';

  static final createTableCommand = '''
    CREATE TABLE $tableName (
      $email TEXT,
      $username TEXT,
      $accessToken TEXT,
      $refreshToken TEXT,
      $type INTEGER NOT NULL
    );
  ''';
}
