import 'dart:math';

import 'package:either_option/either_option.dart';

import '../../../general/services/error_notification_service.dart';
import '../../../general/errors/connection_error.dart';
import '../../../general/errors/server_error.dart';
import '../../../account/services/account_service.dart';
import '../../../general/errors/authentication_token_expired_error.dart';
import '../../../general/utils/policy.dart';
import '../../common/interfaces/ifixture_api_service.dart';
import '../../common/models/entities/fixture_entity.dart';
import '../models/vm/fixture_full_vm.dart';
import '../../../general/persistence/storage.dart';
import '../../../general/errors/error.dart';

class FixtureLivescoreService {
  final Storage _storage;
  final IFixtureApiService _fixtureApiService;
  final AccountService _accountService;
  final ErrorNotificationService _errorNotificationService;

  PolicyExecutor2<ConnectionError, ServerError> _apiPolicy;
  PolicyExecutor<AuthenticationTokenExpiredError> _wsApiPolicy;

  FixtureLivescoreService(
    this._storage,
    this._fixtureApiService,
    this._accountService,
    this._errorNotificationService,
  ) {
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
    );

    _wsApiPolicy = Policy.on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: _accountService.refreshAccessToken,
        ),
      ],
    );
  }

  Future<Either<Error, FixtureFullVm>> loadFixture(
    int fixtureId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var fixtureEntity = await _storage.loadFixtureForTeam(
        fixtureId,
        currentTeam.id,
      );
      if (fixtureEntity.isFullyLoaded) {
        return Right(
          FixtureFullVm.fromEntity(
            currentTeam,
            fixtureEntity,
          ),
        );
      }

      var fixtureDto = await _apiPolicy.execute(
        () => _fixtureApiService.getFixtureForTeam(
          fixtureId,
          currentTeam.id,
        ),
      );

      var performanceRatings = fixtureDto.performanceRatings;
      if (!fixtureDto.isCompletedAndInactive) {
        performanceRatings = fixtureDto
            .buildPerformanceRatingsFromLineupAndEvents(currentTeam.id);
      }

      fixtureEntity = FixtureEntity.fromFullDto(
        currentTeam.id,
        fixtureDto,
        performanceRatings,
      );

      // @@NOTE: Overwrites everything other than performanceRatings, which it updates instead.
      // Returns updated fixture.
      // If fixture is completed and inactive, updates totalRating and totalVoters values for
      // existing performance ratings and adds any missing performance rating entries. Otherwise,
      // simply adds missing performance ratings, since performance ratings artificially constructed
      // on the client do not hold any useful data, their function is to serve as a marker indicating
      // that given player/manager is now counted among fixture participants.
      fixtureEntity = await _storage.updateFixture(fixtureEntity);

      return Right(
        FixtureFullVm.fromEntity(
          currentTeam,
          fixtureEntity,
          shouldSubscribe: fixtureDto.shouldSubscribe,
        ),
      );
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      // @@TODO: In case of an error we probably don't want to just display the error
      // message to the user, but instead show what fixture data is available locally, if any.
      // Load fixture from db and return it with shouldSubscribe == false ??
      // And show a snackbar describing the error ??

      return Left(Error(error.toString()));
    }
  }

  Stream<FixtureFullVm> subscribeToFixture(int fixtureId) async* {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      await for (var update in await _fixtureApiService.subscribeToFixture(
        fixtureId,
        currentTeam.id,
      )) {
        try {
          var performanceRatings =
              update.buildPerformanceRatingsFromLineupAndEvents();

          var fixtureEntity = FixtureEntity.fromLivescoreUpdateDto(
            update,
            performanceRatings,
          );

          fixtureEntity = await _storage.updateFixtureFromLivescore(
            fixtureEntity,
          );

          yield FixtureFullVm.fromEntity(
            currentTeam,
            fixtureEntity,
          );
        } catch (error, stackTrace) {
          print('========== $error ==========');
          print(stackTrace);

          _errorNotificationService.showErrorMessage(error.toString());
        }
      }
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      _errorNotificationService.showErrorMessage(error.toString());
    }
  }

  void unsubscribeFromFixture(int fixtureId) async {
    var currentTeam = await _storage.loadCurrentTeam();
    _fixtureApiService.unsubscribeFromFixture(fixtureId, currentTeam.id);
  }

  Future<FixtureFullVm> rateParticipantOfGivenFixture(
    int fixtureId,
    String participantIdentifier,
    double rating,
  ) async {
    var shouldRevertMyRatingOnError = false;
    double oldRating;
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      oldRating = await _storage.updateMyRatingOfParticipantOfGivenFixture(
        fixtureId,
        currentTeam.id,
        participantIdentifier,
        rating,
      );

      shouldRevertMyRatingOnError = true;

      var performanceRating = await _wsApiPolicy.execute(
        () => _fixtureApiService.rateParticipantOfGivenFixture(
          fixtureId,
          currentTeam.id,
          participantIdentifier,
          rating.floor(),
          oldRating?.floor(),
        ),
      );

      await _storage.updateRatingOfParticipantOfGivenFixture(
        fixtureId,
        currentTeam.id,
        participantIdentifier,
        performanceRating.totalRating,
        performanceRating.totalVoters,
      );

      shouldRevertMyRatingOnError = false;

      var fixture = await _storage.loadFixtureForTeam(
        fixtureId,
        currentTeam.id,
      );

      return FixtureFullVm.fromEntity(currentTeam, fixture);
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      if (shouldRevertMyRatingOnError) {
        var currentTeam = await _storage.loadCurrentTeam();

        await _storage.updateMyRatingOfParticipantOfGivenFixture(
          fixtureId,
          currentTeam.id,
          participantIdentifier,
          oldRating,
        );
      }

      _errorNotificationService.showErrorMessage(error.toString());

      return null;
    }
  }
}
