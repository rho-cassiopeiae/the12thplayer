class DiscussionEntryDto {
  final String id;
  final int userId;
  final String username;
  final String body;

  DiscussionEntryDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        userId = map['userId'],
        username = map['username'],
        body = map['body'];
}
