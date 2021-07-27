import 'package:flutter/foundation.dart';

import '../../enums/video_reaction_vote_action.dart';
import '../dto/video_reaction_dto.dart';

class VideoReactionVm {
  final int authorId;
  final String title;
  final String authorUsername;
  final int rating;
  final String videoId;
  final String thumbnailUrl;
  final VideoReactionVoteAction voteAction;

  VideoReactionVm._(
    this.authorId,
    this.title,
    this.authorUsername,
    this.rating,
    this.videoId,
    this.thumbnailUrl,
    this.voteAction,
  );

  VideoReactionVm.fromDto(VideoReactionDto reaction)
      : authorId = reaction.authorId,
        title = reaction.title,
        authorUsername = reaction.authorUsername,
        rating = reaction.rating,
        videoId = reaction.videoId,
        thumbnailUrl = reaction.thumbnailUrl,
        voteAction = VideoReactionVoteActionExtension.fromInt(
          reaction.voteAction,
        );

  VideoReactionVm copyWith({
    @required int rating,
    @required VideoReactionVoteAction voteAction,
  }) {
    return VideoReactionVm._(
      authorId,
      title,
      authorUsername,
      rating,
      videoId,
      thumbnailUrl,
      voteAction,
    );
  }
}
