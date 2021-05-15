class LiveCommentaryFeedDto {
  final int authorId;
  final String title;
  final String authorUsername;
  final int rating;

  LiveCommentaryFeedDto.fromMap(Map<String, dynamic> map)
      : authorId = map['authorId'],
        title = map['title'],
        authorUsername = map['authorUsername'],
        rating = map['rating'];
}
