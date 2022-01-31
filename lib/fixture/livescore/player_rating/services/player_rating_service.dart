import 'dart:math';

import 'package:either_option/either_option.dart';

import '../../../../general/errors/connection_error.dart';
import '../../../../general/errors/server_error.dart';
import '../../../../general/services/notification_service.dart';
import '../../../../account/services/account_service.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/utils/policy.dart';
import '../interfaces/iplayer_rating_api_service.dart';
import '../models/entities/fixture_player_ratings_entity.dart';
import '../models/vm/player_ratings_vm.dart';
import '../../../../general/persistence/storage.dart';
import '../../../../general/errors/error.dart';

class PlayerRatingService {
  final Storage _storage;
  final AccountService _accountService;
  final IPlayerRatingApiService _playerRatingApiService;
  final NotificationService _notificationService;

  Policy _policy;

  PlayerRatingService(
    this._storage,
    this._accountService,
    this._playerRatingApiService,
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

  Future<Either<Error, PlayerRatingsVm>> loadPlayerRatings(
    int fixtureId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var fixturePlayerRatings =
          await _storage.loadPlayerRatingsForFixture(fixtureId, currentTeam.id);

      if (!fixturePlayerRatings.finalized) {
        var fixturePlayerRatingsDto = await _policy.execute(
          () => _playerRatingApiService.getPlayerRatingsForFixture(
            fixtureId,
            currentTeam.id,
          ),
        );

        fixturePlayerRatings = FixturePlayerRatingsEntity.fromDto(
          fixtureId,
          currentTeam.id,
          fixturePlayerRatingsDto,
        );

        await _storage.savePlayerRatingsForFixture(fixturePlayerRatings);
      }

      var fixture = await _storage.loadFixtureForTeam(
        fixtureId,
        currentTeam.id,
      );

      return Right(
        PlayerRatingsVm.fromEntity(
          fixture,
          fixturePlayerRatings,
        ),
      );
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return Left(Error(error.toString()));
    }
  }

  Future<PlayerRatingsVm> ratePlayer(
    int fixtureId,
    String participantKey,
    double rating,
  ) async {
    var currentTeam = await _storage.loadCurrentTeam();

    try {
      var playerRating = await _policy.execute(
        () => _playerRatingApiService.ratePlayer(
          fixtureId,
          currentTeam.id,
          participantKey,
          rating,
        ),
      );

      var fixturePlayerRatings = await _storage.updatePlayerRating(
        fixtureId,
        currentTeam.id,
        participantKey,
        playerRating.totalRating,
        playerRating.totalVoters,
        rating,
      );

      var fixture = await _storage.loadFixtureForTeam(
        fixtureId,
        currentTeam.id,
      );

      return PlayerRatingsVm.fromEntity(
        fixture,
        fixturePlayerRatings,
      );
    } catch (error) {
      _notificationService.showMessage(error.toString());

      var fixturePlayerRatings =
          await _storage.loadPlayerRatingsForFixture(fixtureId, currentTeam.id);

      var fixture = await _storage.loadFixtureForTeam(
        fixtureId,
        currentTeam.id,
      );

      return PlayerRatingsVm.fromEntity(
        fixture,
        fixturePlayerRatings,
      );
    }
  }
}
