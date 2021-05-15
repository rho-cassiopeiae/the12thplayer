import 'live_commentary_feed_table.dart';

class LiveCommentaryFeedEntryTable {
  static const tableName = 'LiveCommentaryFeedEntry';

  static const fixtureId = 'FixtureId';
  static const teamId = 'TeamId';
  static const authorId = 'AuthorId';
  static const idTime = 'IdTime';
  static const idSeq = 'IdSeq';
  static const time = 'Time';
  static const icon = 'Icon';
  static const title = 'Title';
  static const body = 'Body';
  static const imageUrl = 'ImageUrl';

  static final createTableCommand = '''
    CREATE TABLE $tableName (
      $fixtureId INTEGER NOT NULL,
      $teamId INTEGER NOT NULL,
      $authorId INTEGER NOT NULL,
      $idTime INTEGER NOT NULL,
      $idSeq INTEGER NOT NULL,
      $time TEXT,
      $icon TEXT,
      $title TEXT,
      $body TEXT,
      $imageUrl TEXT,
      PRIMARY KEY ($fixtureId, $teamId, $authorId, $idTime, $idSeq),
      FOREIGN KEY ($fixtureId, $teamId, $authorId)
        REFERENCES ${LiveCommentaryFeedTable.tableName} (${LiveCommentaryFeedTable.fixtureId}, ${LiveCommentaryFeedTable.teamId}, ${LiveCommentaryFeedTable.authorId})
    );
  ''';
}
