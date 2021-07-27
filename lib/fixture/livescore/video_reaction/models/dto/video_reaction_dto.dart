class VideoReactionDto {
  final int authorId;
  final String title;
  final String authorUsername;
  final int rating;
  final String videoId;
  final String thumbnailUrl;
  final int voteAction;

  VideoReactionDto.fromMap(Map<String, dynamic> map)
      : authorId = map['authorId'],
        title = map['title'],
        authorUsername = map['authorUsername'],
        rating = map['rating'],
        videoId = map['videoId'],
        thumbnailUrl = map['thumbnailUrl'],
        voteAction = map.containsKey('voteAction') ? map['voteAction'] : null;
}
