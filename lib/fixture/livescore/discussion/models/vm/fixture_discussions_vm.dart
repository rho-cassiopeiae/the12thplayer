import '../dto/fixture_discussions_dto.dart';
import 'discussion_vm.dart';

class FixtureDiscussionsVm {
  final int fixtureId;
  final List<DiscussionVm> discussions;

  FixtureDiscussionsVm.fromDto(FixtureDiscussionsDto fixtureDiscussions)
      : fixtureId = fixtureDiscussions.fixtureId,
        discussions = fixtureDiscussions.discussions
            .map((discussion) => DiscussionVm.fromDto(discussion))
            .toList() {
    discussions.sort(
      (d1, d2) => _nameToPriority[d1.name].compareTo(_nameToPriority[d2.name]),
    );
  }
}

var _nameToPriority = {
  'pre-match': 1,
  'match': 2,
  'post-match': 3,
};
