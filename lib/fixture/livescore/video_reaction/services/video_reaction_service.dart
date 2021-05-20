import 'dart:math';
import 'dart:typed_data';

import 'package:either_option/either_option.dart';

import '../../../../general/errors/connection_error.dart';
import '../../../../general/errors/server_error.dart';
import '../../../../account/services/account_service.dart';
import '../enums/video_reaction_filter.dart';
import '../enums/video_reaction_vote_action.dart';
import '../interfaces/ivideo_reaction_api_service.dart';
import '../models/vm/fixture_video_reactions_vm.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/persistence/storage.dart';
import '../../../../general/utils/policy.dart';
import '../../../../general/errors/error.dart';

class VideoReactionService {
  final Storage _storage;
  final IVideoReactionApiService _videoReactionApiService;
  final AccountService _accountService;

  PolicyExecutor<AuthenticationTokenExpiredError> _wsApiPolicy;
  PolicyExecutor3<ConnectionError, ServerError, AuthenticationTokenExpiredError>
      _apiPolicy;

  VideoReactionService(
    this._storage,
    this._videoReactionApiService,
    this._accountService,
  ) {
    _wsApiPolicy = Policy.on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: _accountService.refreshAccessToken,
        ),
      ],
    );

    _apiPolicy = Policy.on<ConnectionError>(
      strategies: [
        When(
          any,
          repeat: 1,
          withInterval: (_) => Duration(milliseconds: 200),
        ),
      ],
    ).on<ServerError>(
      strategies: [
        When(
          any,
          repeat: 3,
          withInterval: (attempt) => Duration(
            milliseconds: 200 * pow(2, attempt),
          ),
        ),
      ],
    ).on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: _accountService.refreshAccessToken,
        ),
      ],
    );
  }

  Future<Either<Error, FixtureVideoReactionsVm>> loadVideoReactions(
    int fixtureId,
    VideoReactionFilter filter,
    int start,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var fixtureVideoReactionsDto =
          await _videoReactionApiService.getVideoReactionsForFixture(
        fixtureId,
        currentTeam.id,
        filter,
        start,
      );

      var fixtureVideoReactionVotes =
          await _storage.loadVideoReactionVotesForFixture(
        fixtureId,
        currentTeam.id,
      );

      var fixtureVideoReactionsVm = FixtureVideoReactionsVm.fromDto(
        fixtureVideoReactionsDto,
        fixtureVideoReactionVotes.authorIdToVoteAction,
      );

      return Right(fixtureVideoReactionsVm);
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Stream<Either<Error, FixtureVideoReactionsVm>> voteForVideoReaction(
    int fixtureId,
    int authorId,
    VideoReactionVoteAction voteAction,
    FixtureVideoReactionsVm fixtureVideoReactions,
  ) async* {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var oldVoteAction = await _storage.updateVoteActionForVideoReaction(
        fixtureId,
        currentTeam.id,
        authorId,
        voteAction,
      );

      if (oldVoteAction != null) {
        if (voteAction == oldVoteAction) {
          voteAction = VideoReactionVoteAction.values[voteAction.index + 2];
        } else {
          voteAction = VideoReactionVoteAction.values[voteAction.index + 4];
        }
      }

      int incrScoreBy;
      switch (voteAction) {
        case VideoReactionVoteAction.Upvote:
          incrScoreBy = 1;
          break;
        case VideoReactionVoteAction.Downvote:
          incrScoreBy = -1;
          break;
        case VideoReactionVoteAction.RevertUpvote:
          incrScoreBy = -1;
          break;
        case VideoReactionVoteAction.RevertDownvote:
          incrScoreBy = 1;
          break;
        case VideoReactionVoteAction.RevertDownvoteAndThenUpvote:
          incrScoreBy = 2;
          break;
        case VideoReactionVoteAction.RevertUpvoteAndThenDownvote:
          incrScoreBy = -2;
          break;
      }

      var reactions = fixtureVideoReactions.reactions;
      var index = reactions.indexWhere(
        (reaction) => reaction.authorId == authorId,
      );
      var reaction = reactions[index];
      reactions[index] = reaction.copyWith(
        rating: reaction.rating + incrScoreBy,
        voteAction: voteAction,
      );

      reactions.sort((r1, r2) => r2.rating.compareTo(r1.rating));

      yield Right(fixtureVideoReactions);

      int rating = await _wsApiPolicy.execute(
        () => _videoReactionApiService.voteForVideoReaction(
          fixtureId,
          currentTeam.id,
          authorId,
          voteAction,
        ),
      );

      fixtureVideoReactions = fixtureVideoReactions.copy();
      reactions = fixtureVideoReactions.reactions;
      index = reactions.indexWhere((reaction) => reaction.authorId == authorId);
      reactions[index] = reactions[index].copyWith(rating: rating);
      reactions.sort((r1, r2) => r2.rating.compareTo(r1.rating));

      yield Right(fixtureVideoReactions);
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      yield Left(Error(error.toString()));
    }
  }

  void postVideoReaction(
    int fixtureId,
    String title,
    Uint8List videoBytes,
    String fileName,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var response = await _apiPolicy.execute(
        () => _videoReactionApiService.postVideoReaction(
          fixtureId,
          currentTeam.id,
          title,
          videoBytes,
          fileName,
        ),
      );
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);
    }
  }
}
