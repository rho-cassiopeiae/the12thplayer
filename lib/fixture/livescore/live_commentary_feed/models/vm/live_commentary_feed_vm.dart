import 'package:flutter/foundation.dart';

import '../../enums/live_commentary_feed_vote_action.dart';
import '../dto/live_commentary_feed_dto.dart';

class LiveCommentaryFeedVm {
  final int authorId;
  final String title;
  final String authorUsername;
  final int rating;
  final LiveCommentaryFeedVoteAction voteAction;

  LiveCommentaryFeedVm._(
    this.authorId,
    this.title,
    this.authorUsername,
    this.rating,
    this.voteAction,
  );

  LiveCommentaryFeedVm.fromDto(LiveCommentaryFeedDto feed)
      : authorId = feed.authorId,
        title = feed.title,
        authorUsername = feed.authorUsername,
        rating = feed.rating,
        voteAction = LiveCommentaryFeedVoteActionExtension.fromInt(
          feed.voteAction,
        );

  LiveCommentaryFeedVm copyWith({
    @required int rating,
    @required LiveCommentaryFeedVoteAction voteAction,
  }) {
    return LiveCommentaryFeedVm._(
      authorId,
      title,
      authorUsername,
      rating,
      voteAction,
    );
  }
}
