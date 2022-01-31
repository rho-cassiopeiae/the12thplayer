import '../../../general/extensions/map_extension.dart';

class CommentDto {
  final String id;
  final String rootId;
  final String parentId;
  final int authorId;
  final String authorUsername;
  final int rating;
  final String body;
  final int userVote;

  CommentDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        rootId = map['rootId'],
        parentId = map.getOrNull('parentId'),
        authorId = map['authorId'],
        authorUsername = map['authorUsername'],
        rating = map['rating'],
        body = map['body'],
        userVote = map.getOrNull('userVote');
}
