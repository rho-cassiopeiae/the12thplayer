import 'package:either_option/either_option.dart';

import '../../../../general/services/notification_service.dart';
import '../../../../account/services/account_service.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/utils/policy.dart';
import '../interfaces/iperformance_rating_api_service.dart';
import '../models/entities/fixture_performance_ratings_entity.dart';
import '../models/vm/performance_ratings_vm.dart';
import '../../../../general/persistence/storage.dart';
import '../../../../general/errors/error.dart';

class PerformanceRatingService {
  final Storage _storage;
  final AccountService _accountService;
  final IPerformanceRatingApiService _performanceRatingApiService;
  final NotificationService _notificationService;

  Policy _wsApiPolicy;

  PerformanceRatingService(
    this._storage,
    this._accountService,
    this._performanceRatingApiService,
    this._notificationService,
  ) {
    _wsApiPolicy = PolicyBuilder().on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: _accountService.refreshAccessToken,
        ),
      ],
    ).build();
  }

  Future<Either<Error, PerformanceRatingsVm>> loadPerformanceRatings(
    int fixtureId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var fixturePerformanceRatings = await _storage
          .loadPerformanceRatingsForFixture(fixtureId, currentTeam.id);

      if (!fixturePerformanceRatings.isFinalized) {
        // @@TODO: Policy
        var fixturePerformanceRatingsDto = await _performanceRatingApiService
            .getPerformanceRatingsForFixture(fixtureId, currentTeam.id);

        fixturePerformanceRatings = FixturePerformanceRatingsEntity.fromDto(
          currentTeam.id,
          fixturePerformanceRatingsDto,
        );

        await _storage.savePerformanceRatingsForFixture(
          fixturePerformanceRatings,
        );
      }

      var fixture = await _storage.loadFixtureForTeam(
        fixtureId,
        currentTeam.id,
      );

      return Right(
        PerformanceRatingsVm.fromEntity(
          fixture,
          fixturePerformanceRatings,
        ),
      );
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Future<PerformanceRatingsVm> rateParticipantOfGivenFixture(
    int fixtureId,
    String participantIdentifier,
    double rating,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var performanceRating = await _wsApiPolicy.execute(
        () => _performanceRatingApiService.rateParticipantOfGivenFixture(
          fixtureId,
          currentTeam.id,
          participantIdentifier,
          rating,
        ),
      );

      var fixturePerformanceRatings =
          await _storage.updatePerformanceRatingForFixtureParticipant(
        fixtureId,
        currentTeam.id,
        participantIdentifier,
        performanceRating.totalRating,
        performanceRating.totalVoters,
        rating,
      );

      var fixture = await _storage.loadFixtureForTeam(
        fixtureId,
        currentTeam.id,
      );

      return PerformanceRatingsVm.fromEntity(
        fixture,
        fixturePerformanceRatings,
      );
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      var currentTeam = await _storage.loadCurrentTeam();

      var fixturePerformanceRatings = await _storage
          .loadPerformanceRatingsForFixture(fixtureId, currentTeam.id);

      var fixture = await _storage.loadFixtureForTeam(
        fixtureId,
        currentTeam.id,
      );

      _notificationService.showMessage(error.toString());

      return PerformanceRatingsVm.fromEntity(
        fixture,
        fixturePerformanceRatings,
      );
    }
  }
}
