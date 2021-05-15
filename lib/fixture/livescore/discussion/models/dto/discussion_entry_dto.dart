class DiscussionEntryDto {
  final String id;
  final String username;
  final String body;

  DiscussionEntryDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        username = map['username'],
        body = map['body'];
}
