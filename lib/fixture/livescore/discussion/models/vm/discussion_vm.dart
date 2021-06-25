import '../dto/discussion_dto.dart';

class DiscussionVm {
  final String identifier;
  final String name;
  final bool isActive;

  DiscussionVm.fromDto(DiscussionDto discussion)
      : identifier = discussion.identifier,
        name = discussion.name,
        isActive = discussion.isActive;
}
