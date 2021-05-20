import 'package:flutter/foundation.dart';

import '../models/vm/fixture_video_reactions_vm.dart';

abstract class VideoReactionState {}

abstract class LoadVideoReactionsState extends VideoReactionState {}

class VideoReactionsLoading extends LoadVideoReactionsState {}

class VideoReactionsReady extends LoadVideoReactionsState {
  final FixtureVideoReactionsVm fixtureVideoReactions;

  VideoReactionsReady({@required this.fixtureVideoReactions});
}

class VideoReactionsError extends LoadVideoReactionsState {
  final String message;

  VideoReactionsError({@required this.message});
}

abstract class PostVideoReactionState extends VideoReactionState {}

class PostVideoReactionInProgress extends PostVideoReactionState {}

class PostVideoReactionError extends PostVideoReactionState {
  final String message;

  PostVideoReactionError({@required this.message});
}
