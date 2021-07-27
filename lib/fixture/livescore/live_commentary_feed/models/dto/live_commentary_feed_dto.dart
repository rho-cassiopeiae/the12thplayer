class LiveCommentaryFeedDto {
  final int authorId;
  final String title;
  final String authorUsername;
  final int rating;
  final int voteAction;

  LiveCommentaryFeedDto.fromMap(Map<String, dynamic> map)
      : authorId = map['authorId'],
        title = map['title'],
        authorUsername = map['authorUsername'],
        rating = map['rating'],
        voteAction = map.containsKey('voteAction') ? map['voteAction'] : null;
}
