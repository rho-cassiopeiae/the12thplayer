import '../dto/discussion_dto.dart';
import 'discussion_vm.dart';

class FixtureDiscussionsVm {
  final List<DiscussionVm> discussions;

  FixtureDiscussionsVm.fromDto(Iterable<DiscussionDto> discussions)
      : discussions = discussions
            .map((discussion) => DiscussionVm.fromDto(discussion))
            .toList() {
    this.discussions.sort(
          (d1, d2) =>
              _nameToPriority[d1.name].compareTo(_nameToPriority[d2.name]),
        );
  }
}

var _nameToPriority = {
  'pre-match': 1,
  'match': 2,
  'post-match': 3,
};
