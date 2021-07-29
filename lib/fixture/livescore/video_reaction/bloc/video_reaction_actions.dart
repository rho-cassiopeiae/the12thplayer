import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../enums/video_reaction_vote_action.dart';
import '../models/vm/fixture_video_reactions_vm.dart';
import '../enums/video_reaction_filter.dart';
import 'video_reaction_states.dart';

abstract class VideoReactionAction {}

abstract class VideoReactionActionFutureState<TState extends VideoReactionState>
    extends VideoReactionAction {
  final Completer<TState> _stateReady = Completer<TState>();
  Future<TState> get state => _stateReady.future;

  void complete(TState state) => _stateReady.complete(state);
}

class LoadVideoReactions extends VideoReactionAction {
  final int fixtureId;
  final VideoReactionFilter filter;
  final int start;

  LoadVideoReactions({
    @required this.fixtureId,
    @required this.filter,
    @required this.start,
  });
}

class VoteForVideoReaction extends VideoReactionAction {
  final int fixtureId;
  final int authorId;
  final VideoReactionVoteAction voteAction;
  final FixtureVideoReactionsVm fixtureVideoReactions;

  VoteForVideoReaction({
    @required this.fixtureId,
    @required this.authorId,
    @required this.voteAction,
    @required this.fixtureVideoReactions,
  });
}

class PostVideoReaction extends VideoReactionAction {
  final int fixtureId;
  final String title;
  final Uint8List videoBytes;
  final String fileName;

  PostVideoReaction({
    @required this.fixtureId,
    @required this.title,
    @required this.videoBytes,
    @required this.fileName,
  });
}

class GetVideoQualityUrls
    extends VideoReactionActionFutureState<GetVideoQualityUrlsState> {
  final String videoId;

  GetVideoQualityUrls({@required this.videoId});
}
