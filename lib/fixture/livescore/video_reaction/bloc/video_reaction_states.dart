import 'package:flutter/foundation.dart';

import '../models/vm/fixture_video_reactions_vm.dart';

abstract class VideoReactionState {}

abstract class LoadVideoReactionsState extends VideoReactionState {}

class VideoReactionsLoading extends LoadVideoReactionsState {}

class VideoReactionsReady extends LoadVideoReactionsState {
  final FixtureVideoReactionsVm fixtureVideoReactions;

  VideoReactionsReady({@required this.fixtureVideoReactions});
}

abstract class GetVideoQualityUrlsState extends VideoReactionState {}

class VideoQualityUrlsLoading extends GetVideoQualityUrlsState {}

class VideoQualityUrlsReady extends GetVideoQualityUrlsState {
  final Map<String, String> qualityToUrl;

  VideoQualityUrlsReady({@required this.qualityToUrl});
}

class VideoQualityUrlsError extends GetVideoQualityUrlsState {}
