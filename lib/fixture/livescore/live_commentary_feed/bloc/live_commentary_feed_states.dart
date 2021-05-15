import 'package:flutter/foundation.dart';

import '../models/vm/fixture_live_commentary_feeds_vm.dart';
import '../models/vm/live_commentary_feed_entry_vm.dart';

abstract class LiveCommentaryFeedState {}

abstract class LoadLiveCommentaryFeedsState extends LiveCommentaryFeedState {}

class LiveCommentaryFeedsLoading extends LoadLiveCommentaryFeedsState {}

class LiveCommentaryFeedsReady extends LoadLiveCommentaryFeedsState {
  final FixtureLiveCommentaryFeedsVm fixtureLiveCommentaryFeeds;

  LiveCommentaryFeedsReady({@required this.fixtureLiveCommentaryFeeds});
}

class LiveCommentaryFeedsError extends LoadLiveCommentaryFeedsState {
  final String message;

  LiveCommentaryFeedsError({@required this.message});
}

abstract class LoadLiveCommentaryFeedState extends LiveCommentaryFeedState {}

class LiveCommentaryFeedLoading extends LoadLiveCommentaryFeedState {}

class LiveCommentaryFeedReady extends LoadLiveCommentaryFeedState {
  final List<LiveCommentaryFeedEntryVm> entries;

  LiveCommentaryFeedReady({@required this.entries});
}

class LiveCommentaryFeedError extends LoadLiveCommentaryFeedState {
  final String message;

  LiveCommentaryFeedError({@required this.message});
}
