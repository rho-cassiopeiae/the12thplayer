import '../dto/discussion_dto.dart';

class DiscussionEntity {
  final String identifier;
  final String name;
  final bool isActive;

  DiscussionEntity.fromDto(DiscussionDto discussion)
      : identifier = discussion.identifier,
        name = discussion.name,
        isActive = discussion.isActive;

  DiscussionEntity.fromMap(Map<String, dynamic> map)
      : identifier = map['identifier'],
        name = map['name'],
        isActive = map['isActive'];

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['identifier'] = identifier;
    map['name'] = name;
    map['isActive'] = isActive;

    return map;
  }
}
