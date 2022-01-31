import '../dto/discussion_dto.dart';

class DiscussionVm {
  final String id;
  final String name;
  final bool active;

  DiscussionVm.fromDto(DiscussionDto discussion)
      : id = discussion.id,
        name = discussion.name,
        active = discussion.active;
}
