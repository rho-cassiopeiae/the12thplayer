import '../../../../../general/extensions/map_extension.dart';

class VideoReactionDto {
  final int authorId;
  final String title;
  final String authorUsername;
  final int rating;
  final String videoId;
  final int userVote;

  VideoReactionDto.fromMap(Map<String, dynamic> map)
      : authorId = map['authorId'],
        title = map['title'],
        authorUsername = map['authorUsername'],
        rating = map['rating'],
        videoId = map['videoId'],
        userVote = map.getOrNull('userVote');
}
