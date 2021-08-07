class ArticleDto {
  final int postedAt;
  final int authorId;
  final String authorUsername;
  final int type;
  final String title;
  final String previewImageUrl;
  final String summary;
  final String content;

  ArticleDto.fromMap(Map<String, dynamic> map)
      : postedAt = map['postedAt'],
        authorId = map['authorId'],
        authorUsername = map['authorUsername'],
        type = map['type'],
        title = map['title'],
        previewImageUrl =
            map.containsKey('previewImageUrl') ? map['previewImageUrl'] : null,
        summary = map.containsKey('summary') ? map['summary'] : null,
        content = map['content'];
}
