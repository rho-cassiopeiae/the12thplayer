class DiscussionDto {
  final String identifier;
  final String name;
  final bool isActive;

  DiscussionDto.fromMap(Map<String, dynamic> map)
      : identifier = map['identifier'],
        name = map['name'],
        isActive = map['isActive'];
}
