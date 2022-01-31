import '../models/dto/discussion_dto.dart';
import '../models/dto/discussion_entry_dto.dart';
import '../models/dto/fixture_discussion_update_dto.dart';

abstract class IDiscussionApiService {
  Future<Iterable<DiscussionDto>> getDiscussionsForFixture(
    int fixtureId,
    int teamId,
  );

  Future<Stream<FixtureDiscussionUpdateDto>> subscribeToDiscussion(
    int fixtureId,
    int teamId,
    String discussionId,
  );

  Future<Iterable<DiscussionEntryDto>> getMoreDiscussionEntries(
    int fixtureId,
    int teamId,
    String discussionId,
    String lastReceivedEntryId,
  );

  Future unsubscribeFromDiscussion(
    int fixtureId,
    int teamId,
    String discussionId,
  );

  Future postDiscussionEntry(
    int fixtureId,
    int teamId,
    String discussionId,
    String body,
  );
}
