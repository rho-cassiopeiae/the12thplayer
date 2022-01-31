import 'dart:math';
import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:either_option/either_option.dart';

import '../../../../general/services/notification_service.dart';
import '../interfaces/ivimeo_api_service.dart';
import '../../../../general/errors/connection_error.dart';
import '../../../../general/errors/server_error.dart';
import '../../../../account/services/account_service.dart';
import '../enums/video_reaction_filter.dart';
import '../interfaces/ivideo_reaction_api_service.dart';
import '../models/vm/fixture_video_reactions_vm.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/persistence/storage.dart';
import '../../../../general/utils/policy.dart';
import '../../../../general/errors/error.dart';

class VideoReactionService {
  final Storage _storage;
  final IVideoReactionApiService _videoReactionApiService;
  final IVimeoApiService _vimeoApiService;
  final AccountService _accountService;
  final NotificationService _notificationService;

  Policy _policy;

  int _notificationId = 0;

  VideoReactionService(
    this._storage,
    this._videoReactionApiService,
    this._vimeoApiService,
    this._accountService,
    this._notificationService,
  ) {
    _policy = PolicyBuilder().on<ConnectionError>(
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
    ).build();
  }

  Future<FixtureVideoReactionsVm> loadVideoReactions(
    int fixtureId,
    VideoReactionFilter filter,
    int page,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var fixtureVideoReactions = await _policy.execute(
        () => _videoReactionApiService.getVideoReactionsForFixture(
          fixtureId,
          currentTeam.id,
          filter,
          page,
        ),
      );

      _storage.addVideoReactions(
        FixtureVideoReactionsVm.fromDto(fixtureVideoReactions),
      );
    } catch (error) {
      _notificationService.showMessage(error.toString());
    }

    return _storage.getVideoReactions();
  }

  Future<FixtureVideoReactionsVm> voteForVideoReaction(
    int fixtureId,
    int authorId,
    int userVote,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var videoReactionRating = await _policy.execute(
        () => _videoReactionApiService.voteForVideoReaction(
          fixtureId,
          currentTeam.id,
          authorId,
          userVote,
        ),
      );

      var fixtureVideoReactions = _storage.getVideoReactions().copy();
      var videoReactions = fixtureVideoReactions.videoReactions;
      var index = videoReactions.indexWhere((vr) => vr.authorId == authorId);
      if (index >= 0) {
        videoReactions[index] = videoReactions[index].copyWith(
          rating: videoReactionRating.rating,
          userVote: userVote,
        );

        _storage.setVideoReactions(fixtureVideoReactions);
      }
    } catch (error) {
      _notificationService.showMessage(error.toString());
    }

    return _storage.getVideoReactions();
  }

  void postVideoReaction(
    int fixtureId,
    String title,
    Uint8List videoBytes,
    String fileName,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      _notificationService.showMessage('Video will be published shortly');

      await _policy.execute(
        () => _videoReactionApiService.postVideoReaction(
          fixtureId,
          currentTeam.id,
          title,
          videoBytes,
          fileName,
        ),
      );
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return;
    }

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: ++_notificationId,
        channelKey: 'video_reaction_channel',
        title: 'Your video is ready',
        body: 'It\'s successfully published and now available to everyone',
      ),
    );
  }

  Future<Either<Error, Map<String, String>>> getVideoQualityUrls(
    String videoId,
  ) async {
    try {
      var qualityToUrl = await _policy.execute(
        () => _vimeoApiService.getVideoQualityUrls(videoId),
      );

      return Right(qualityToUrl);
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return Left(Error(error.toString()));
    }
  }
}
