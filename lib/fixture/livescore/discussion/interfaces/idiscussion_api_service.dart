import '../models/dto/fixture_discussions_dto.dart';
import '../models/dto/discussion_entry_dto.dart';
import '../models/dto/fixture_discussion_update_dto.dart';

abstract class IDiscussionApiService {
  Future<FixtureDiscussionsDto> getDiscussionsForFixture(
    int fixtureId,
    int teamId,
  );

  Future<Stream<FixtureDiscussionUpdateDto>> subscribeToDiscussion(
    int fixtureId,
    int teamId,
    String discussionIdentifier,
  );

  Future<Iterable<DiscussionEntryDto>> getMoreDiscussionEntries(
    int fixtureId,
    int teamId,
    String discussionIdentifier,
    String lastReceivedEntryId,
  );

  void unsubscribeFromDiscussion(
    int fixtureId,
    int teamId,
    String discussionIdentifier,
  );

  Future postDiscussionEntry(
    int fixtureId,
    int teamId,
    String discussionIdentifier,
    String body,
  );
}
