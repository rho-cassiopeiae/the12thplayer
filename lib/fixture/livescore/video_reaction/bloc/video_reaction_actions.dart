import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../../../general/bloc/mixins.dart';
import '../enums/video_reaction_filter.dart';
import 'video_reaction_states.dart';

abstract class VideoReactionAction {}

abstract class VideoReactionActionAwaitable<T extends VideoReactionState>
    extends VideoReactionAction with AwaitableState<T> {}

class LoadVideoReactions extends VideoReactionAction {
  final int fixtureId;
  final VideoReactionFilter filter;
  final int page;

  LoadVideoReactions({
    @required this.fixtureId,
    @required this.filter,
    @required this.page,
  });
}

class VoteForVideoReaction extends VideoReactionAction {
  final int fixtureId;
  final int authorId;
  final int userVote;

  VoteForVideoReaction({
    @required this.fixtureId,
    @required this.authorId,
    @required this.userVote,
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
    extends VideoReactionActionAwaitable<GetVideoQualityUrlsState> {
  final String videoId;

  GetVideoQualityUrls({@required this.videoId});
}
