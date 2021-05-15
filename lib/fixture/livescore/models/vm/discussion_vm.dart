import '../../../common/models/entities/discussion_entity.dart';

class DiscussionVm {
  final String identifier;
  final String name;
  final bool isActive;

  DiscussionVm.fromEntity(DiscussionEntity discussion)
      : identifier = discussion.identifier,
        name = discussion.name,
        isActive = discussion.isActive;
}
