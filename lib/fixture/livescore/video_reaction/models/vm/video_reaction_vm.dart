import '../../enums/video_reaction_vote_action.dart';
import '../dto/video_reaction_dto.dart';

class VideoReactionVm {
  final int authorId;
  final String title;
  final String authorUsername;
  final int rating;
  final String videoId;
  final String thumbnailUrl;
  final VideoReactionVoteAction _voteAction;

  bool get upvoted =>
      _voteAction == VideoReactionVoteAction.Upvote ||
      _voteAction == VideoReactionVoteAction.RevertDownvoteAndThenUpvote;

  bool get downvoted =>
      _voteAction == VideoReactionVoteAction.Downvote ||
      _voteAction == VideoReactionVoteAction.RevertUpvoteAndThenDownvote;

  VideoReactionVm._(
    this.authorId,
    this.title,
    this.authorUsername,
    this.rating,
    this.videoId,
    this.thumbnailUrl,
    this._voteAction,
  );

  VideoReactionVm.fromDto(
    VideoReactionDto reaction,
    Map<int, VideoReactionVoteAction> authorIdToVoteAction,
  )   : authorId = reaction.authorId,
        title = reaction.title,
        authorUsername = reaction.authorUsername,
        rating = reaction.rating,
        videoId = reaction.videoId,
        thumbnailUrl = reaction.thumbnailUrl,
        _voteAction = authorIdToVoteAction.containsKey(reaction.authorId)
            ? authorIdToVoteAction[reaction.authorId]
            : null;

  VideoReactionVm copyWith({
    int rating,
    VideoReactionVoteAction voteAction,
  }) {
    return VideoReactionVm._(
      authorId,
      title,
      authorUsername,
      rating ?? this.rating,
      videoId,
      thumbnailUrl,
      voteAction ?? _voteAction,
    );
  }
}
