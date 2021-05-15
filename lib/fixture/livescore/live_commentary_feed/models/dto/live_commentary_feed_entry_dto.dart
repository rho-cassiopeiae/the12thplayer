class LiveCommentaryFeedEntryDto {
  final String id;
  final String time;
  final String icon;
  final String title;
  final String body;
  final String imageUrl;

  LiveCommentaryFeedEntryDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        time = map['time'],
        icon = map['icon'],
        title = map['title'],
        body = map['body'],
        imageUrl = map['imageUrl'];
}
