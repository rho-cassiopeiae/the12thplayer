class AccountTable {
  static const tableName = 'Account';

  static const deviceId = 'DeviceId';
  static const email = 'Email';
  static const username = 'Username';
  static const accessToken = 'AccessToken';
  static const refreshToken = 'RefreshToken';
  static const type = 'Type';

  static final createTableCommand = '''
    CREATE TABLE $tableName (
      $deviceId TEXT NOT NULL,
      $email TEXT,
      $username TEXT,
      $accessToken TEXT,
      $refreshToken TEXT,
      $type INTEGER NOT NULL
    );
  ''';
}
