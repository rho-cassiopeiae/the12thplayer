import '../dto/fixture_live_commentary_feeds_dto.dart';
import 'live_commentary_feed_vm.dart';

class FixtureLiveCommentaryFeedsVm {
  final int fixtureId;
  final bool ongoing;
  final List<LiveCommentaryFeedVm> feeds;

  FixtureLiveCommentaryFeedsVm._(
    this.fixtureId,
    this.ongoing,
    this.feeds,
  );

  FixtureLiveCommentaryFeedsVm.fromDto(
    FixtureLiveCommentaryFeedsDto fixtureLiveCommFeeds,
  )   : fixtureId = fixtureLiveCommFeeds.fixtureId,
        ongoing = fixtureLiveCommFeeds.ongoing,
        feeds = fixtureLiveCommFeeds.feeds
            .map((feed) => LiveCommentaryFeedVm.fromDto(feed))
            .toList();

  FixtureLiveCommentaryFeedsVm copy() {
    return FixtureLiveCommentaryFeedsVm._(
      fixtureId,
      ongoing,
      List<LiveCommentaryFeedVm>.from(feeds),
    );
  }
}
