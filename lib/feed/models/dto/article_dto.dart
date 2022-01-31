import '../../../general/extensions/map_extension.dart';

class ArticleDto {
  final int id;
  final int authorId;
  final String authorUsername;
  final int postedAt;
  final int type;
  final String title;
  final String previewImageUrl;
  final String summary;
  final String content;
  final int rating;
  final int commentCount;
  final int userVote;

  ArticleDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        authorId = map['authorId'],
        authorUsername = map['authorUsername'],
        postedAt = map['postedAt'],
        type = map['type'],
        title = map['title'],
        previewImageUrl = map.getOrNull('previewImageUrl'),
        summary = map.getOrNull('summary'),
        content = map.getOrNull('content'),
        rating = map['rating'],
        commentCount = map['commentCount'],
        userVote = map.getOrNull('userVote');
}
