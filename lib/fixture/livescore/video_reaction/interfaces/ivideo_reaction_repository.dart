import '../enums/video_reaction_vote_action.dart';
import '../models/entities/fixture_video_reaction_votes_entity.dart';

abstract class IVideoReactionRepository {
  Future<FixtureVideoReactionVotesEntity> loadVideoReactionVotesForFixture(
    int fixtureId,
    int teamId,
  );

  Future<VideoReactionVoteAction> updateVoteActionForVideoReaction(
    int fixtureId,
    int teamId,
    int authorId,
    VideoReactionVoteAction voteAction,
  );
}
