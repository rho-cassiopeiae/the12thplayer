import '../../enums/live_commentary_feed_vote_action.dart';
import '../dto/live_commentary_feed_dto.dart';

class LiveCommentaryFeedVm {
  final int authorId;
  final String title;
  final String authorUsername;
  final int rating;
  final LiveCommentaryFeedVoteAction _voteAction;

  bool get upvoted =>
      _voteAction == LiveCommentaryFeedVoteAction.Upvote ||
      _voteAction == LiveCommentaryFeedVoteAction.RevertDownvoteAndThenUpvote;

  bool get downvoted =>
      _voteAction == LiveCommentaryFeedVoteAction.Downvote ||
      _voteAction == LiveCommentaryFeedVoteAction.RevertUpvoteAndThenDownvote;

  LiveCommentaryFeedVm._(
    this.authorId,
    this.title,
    this.authorUsername,
    this.rating,
    this._voteAction,
  );

  LiveCommentaryFeedVm.fromDto(
    LiveCommentaryFeedDto feed,
    Map<int, LiveCommentaryFeedVoteAction> authorIdToVoteAction,
  )   : authorId = feed.authorId,
        title = feed.title,
        authorUsername = feed.authorUsername,
        rating = feed.rating,
        _voteAction = authorIdToVoteAction.containsKey(feed.authorId)
            ? authorIdToVoteAction[feed.authorId]
            : null;

  LiveCommentaryFeedVm copyWith({
    int rating,
    LiveCommentaryFeedVoteAction voteAction,
  }) {
    return LiveCommentaryFeedVm._(
      authorId,
      title,
      authorUsername,
      rating ?? this.rating,
      voteAction ?? _voteAction,
    );
  }
}
