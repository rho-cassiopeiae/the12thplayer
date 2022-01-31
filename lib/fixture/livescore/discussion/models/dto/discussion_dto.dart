class DiscussionDto {
  final String id;
  final String name;
  final bool active;

  DiscussionDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        active = map['active'];
}
