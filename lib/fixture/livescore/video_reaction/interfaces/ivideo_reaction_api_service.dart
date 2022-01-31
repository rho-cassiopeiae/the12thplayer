import 'dart:typed_data';

import '../models/dto/video_reaction_rating_dto.dart';
import '../enums/video_reaction_filter.dart';
import '../models/dto/fixture_video_reactions_dto.dart';

abstract class IVideoReactionApiService {
  Future<FixtureVideoReactionsDto> getVideoReactionsForFixture(
    int fixtureId,
    int teamId,
    VideoReactionFilter filter,
    int page,
  );

  Future<VideoReactionRatingDto> voteForVideoReaction(
    int fixtureId,
    int teamId,
    int authorId,
    int userVote,
  );

  Future<String> postVideoReaction(
    int fixtureId,
    int teamId,
    String title,
    Uint8List videoBytes,
    String fileName,
  );
}
