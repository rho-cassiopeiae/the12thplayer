enum LiveCommentaryFeedVoteAction {
  Upvote,
  Downvote,
}

extension LiveCommentaryFeedVoteActionExtension
    on LiveCommentaryFeedVoteAction {
  int toInt() => this == LiveCommentaryFeedVoteAction.Upvote ? 1 : -1;

  static LiveCommentaryFeedVoteAction fromInt(int value) => value == 1
      ? LiveCommentaryFeedVoteAction.Upvote
      : value == -1
          ? LiveCommentaryFeedVoteAction.Downvote
          : null;
}
