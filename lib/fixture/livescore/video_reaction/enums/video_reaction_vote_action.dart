enum VideoReactionVoteAction {
  Upvote,
  Downvote,
}

extension VideoReactionVoteActionExtension on VideoReactionVoteAction {
  int toInt() => this == VideoReactionVoteAction.Upvote ? 1 : -1;

  static VideoReactionVoteAction fromInt(int value) => value == 1
      ? VideoReactionVoteAction.Upvote
      : value == -1
          ? VideoReactionVoteAction.Downvote
          : null;
}
