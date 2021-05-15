class FixtureLiveCommentaryFeedVotesTable {
  static const tableName = 'FixtureLiveCommentaryFeedVotes';

  static const fixtureId = 'FixtureId';
  static const teamId = 'TeamId';
  static const authorIdToVoteAction = 'AuthorIdToVoteAction';

  static final createTableCommand = '''
    CREATE TABLE $tableName (
      $fixtureId INTEGER NOT NULL,
      $teamId INTEGER NOT NULL,
      $authorIdToVoteAction TEXT NOT NULL,
      PRIMARY KEY ($fixtureId, $teamId)
    );
  ''';
}
