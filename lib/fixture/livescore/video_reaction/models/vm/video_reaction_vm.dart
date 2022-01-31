import 'package:flutter/foundation.dart';

import '../dto/video_reaction_dto.dart';

class VideoReactionVm {
  final int authorId;
  final String title;
  final String authorUsername;
  final int rating;
  final String videoId;
  final int userVote;

  VideoReactionVm._(
    this.authorId,
    this.title,
    this.authorUsername,
    this.rating,
    this.videoId,
    this.userVote,
  );

  VideoReactionVm.fromDto(VideoReactionDto reaction)
      : authorId = reaction.authorId,
        title = reaction.title,
        authorUsername = reaction.authorUsername,
        rating = reaction.rating,
        videoId = reaction.videoId,
        userVote = reaction.userVote;

  VideoReactionVm copyWith({
    @required int rating,
    @required int userVote,
  }) =>
      VideoReactionVm._(
        authorId,
        title,
        authorUsername,
        rating,
        videoId,
        userVote,
      );
}
