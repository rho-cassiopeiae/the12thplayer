import 'dart:typed_data';

import '../models/dto/voted_for_video_reaction_dto.dart';
import '../models/dto/posted_video_reaction_dto.dart';
import '../enums/video_reaction_vote_action.dart';
import '../enums/video_reaction_filter.dart';
import '../models/dto/fixture_video_reactions_dto.dart';

abstract class IVideoReactionApiService {
  Future<FixtureVideoReactionsDto> getVideoReactionsForFixture(
    int fixtureId,
    int teamId,
    VideoReactionFilter filter,
    int start,
  );

  Future<VotedForVideoReactionDto> voteForVideoReaction(
    int fixtureId,
    int teamId,
    int authorId,
    VideoReactionVoteAction voteAction,
  );

  Future<PostedVideoReactionDto> postVideoReaction(
    int fixtureId,
    int teamId,
    String title,
    Uint8List videoBytes,
    String fileName,
  );
}
