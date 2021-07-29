import 'dart:math';

import 'package:either_option/either_option.dart';

import '../../../general/services/notification_service.dart';
import '../../../general/errors/connection_error.dart';
import '../../../general/errors/server_error.dart';
import '../../../general/utils/policy.dart';
import '../../common/interfaces/ifixture_api_service.dart';
import '../../common/models/entities/fixture_entity.dart';
import '../models/vm/fixture_full_vm.dart';
import '../../../general/persistence/storage.dart';
import '../../../general/errors/error.dart';

class FixtureLivescoreService {
  final Storage _storage;
  final IFixtureApiService _fixtureApiService;
  final NotificationService _notificationService;

  Policy _apiPolicy;

  FixtureLivescoreService(
    this._storage,
    this._fixtureApiService,
    this._notificationService,
  ) {
    _apiPolicy = PolicyBuilder().on<ConnectionError>(
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
    ).build();
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

      if (!fixtureEntity.isFullyLoaded) {
        var fixtureDto = await _apiPolicy.execute(
          () => _fixtureApiService.getFixtureForTeam(
            fixtureId,
            currentTeam.id,
          ),
        );

        fixtureEntity = FixtureEntity.fromFullDto(currentTeam.id, fixtureDto);

        await _storage.updateFixture(fixtureEntity);
      }

      return Right(FixtureFullVm.fromEntity(currentTeam, fixtureEntity));
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      // @@TODO: In case of an error we probably don't want to just display the error
      // message to the user, but instead show fixture data available locally, if any.

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
          var fixtureEntity = FixtureEntity.fromLivescoreUpdateDto(update);

          fixtureEntity =
              await _storage.updateFixtureFromLivescore(fixtureEntity);

          yield FixtureFullVm.fromEntity(
            currentTeam,
            fixtureEntity,
          );
        } catch (error, stackTrace) {
          print('========== $error ==========');
          print(stackTrace);

          _notificationService.showMessage(error.toString());
        }
      }
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      _notificationService.showMessage(error.toString());
    }
  }

  void unsubscribeFromFixture(int fixtureId) async {
    var currentTeam = await _storage.loadCurrentTeam();
    _fixtureApiService.unsubscribeFromFixture(fixtureId, currentTeam.id);
  }
}
