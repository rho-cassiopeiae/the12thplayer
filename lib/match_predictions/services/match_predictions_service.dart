import 'dart:math';

import '../models/vm/game_time_vm.dart';
import '../models/vm/score_vm.dart';
import '../../account/services/account_service.dart';
import '../../general/errors/authentication_token_expired_error.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../../general/persistence/storage.dart';
import '../../general/services/notification_service.dart';
import '../../general/utils/policy.dart';
import '../interfaces/imatch_predictions_api_service.dart';
import '../models/vm/active_season_round_with_fixtures_vm.dart';

class MatchPredictionsService {
  final Storage _storage;
  final IMatchPredictionsApiService _matchPredictionsApiService;
  final AccountService _accountService;
  final NotificationService _notificationService;

  Policy _policy;

  MatchPredictionsService(
    this._storage,
    this._matchPredictionsApiService,
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

  Future<ActiveSeasonRoundWithFixturesVm> loadActiveFixtures(
    bool clearDraftPredictions,
  ) async {
    try {
      if (clearDraftPredictions) {
        _storage.clearDraftPredictions();
      }

      var currentTeam = await _storage.loadCurrentTeam();

      var seasonRounds = await _policy.execute(
        () => _matchPredictionsApiService.getActiveFixturesForTeam(
          currentTeam.id,
        ),
      );

      // @@NOTE: We only handle one competition for now.
      var seasonRound = ActiveSeasonRoundWithFixturesVm.fromDto(
        seasonRounds.first,
      );

      for (var prediction in _storage.getDraftPredictions().entries) {
        var fixtures = seasonRound.fixtures;
        int index = fixtures.indexWhere((f) => f.id == prediction.key);
        if (index >= 0) {
          fixtures[index] = fixtures[index].copyWith(
            predictedScore: prediction.value,
          );
        }
      }

      _storage.setActiveSeasonRound(seasonRound);
    } catch (error, stacktrace) {
      print(error);
      print(stacktrace);
      _notificationService.showMessage(error.toString());
    }

    return _storage.getActiveSeasonRound();
  }

  ActiveSeasonRoundWithFixturesVm addDraftPrediction(
    int fixtureId,
    String score,
  ) {
    _storage.addDraftPrediction(fixtureId, score);
    var seasonRound = _storage.getActiveSeasonRound().copy();
    for (var prediction in _storage.getDraftPredictions().entries) {
      var fixtures = seasonRound.fixtures;
      int index = fixtures.indexWhere((f) => f.id == prediction.key);
      if (index >= 0) {
        fixtures[index] = fixtures[index].copyWith(
          predictedScore: prediction.value,
        );
      }
    }

    _storage.setActiveSeasonRound(seasonRound);

    return _storage.getActiveSeasonRound();
  }

  Future<ActiveSeasonRoundWithFixturesVm> submitMatchPredictions() async {
    try {
      // @@TODO: Validation.

      var seasonRound = _storage.getActiveSeasonRound();
      if (seasonRound != null) {
        var draftPredictions = _storage.getDraftPredictions();

        var submission = await _policy.execute(
          () => _matchPredictionsApiService.submitMatchPredictions(
            seasonRound.seasonId,
            seasonRound.roundId,
            draftPredictions,
          ),
        );

        seasonRound = _storage.getActiveSeasonRound().copy();
        var fixtures = seasonRound.fixtures;

        if (submission.updatedPredictions != null) {
          // @@NOTE: Returns all saved predictions even if none of them have actually been changed.
          for (var prediction in submission.updatedPredictions.entries) {
            var fixtureId = int.parse(prediction.key);
            int index = fixtures.indexWhere((f) => f.id == fixtureId);
            if (index >= 0) {
              fixtures[index] = fixtures[index].copyWith(
                predictedScore: prediction.value,
              );
            }
          }
        }

        if (submission.alreadyStartedFixtures != null) {
          // @@NOTE: Means some of the submitted predictions were new but no longer
          // applicable (i.e., for already started fixtures).
          for (var fixture in submission.alreadyStartedFixtures) {
            int index = fixtures.indexWhere((f) => f.id == fixture.id);
            if (index >= 0) {
              fixtures[index] = fixtures[index].copyWith(
                startTime: DateTime.fromMillisecondsSinceEpoch(
                  fixture.startTime,
                ),
                status: fixture.status.replaceAll('_', ' '),
                gameTime: GameTimeVm.fromDto(fixture.gameTime),
                score: ScoreVm.fromDto(fixture.score),
              );
            }
          }
        }

        _storage.clearDraftPredictions();
        _storage.setActiveSeasonRound(seasonRound);

        _notificationService.showMessage('Predictions submitted successfully');
      }
    } catch (error, stacktrace) {
      print(error);
      print(stacktrace);
      _notificationService.showMessage(error.toString());
    }

    return _storage.getActiveSeasonRound();
  }
}
