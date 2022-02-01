import 'dart:math';

import 'package:tuple/tuple.dart';

import '../../../general/services/notification_service.dart';
import '../../../general/errors/connection_error.dart';
import '../../../general/errors/server_error.dart';
import '../../../general/utils/policy.dart';
import '../../common/interfaces/ifixture_api_service.dart';
import '../../common/models/entities/fixture_entity.dart';
import '../models/vm/fixture_full_vm.dart';
import '../../../general/persistence/storage.dart';

class FixtureLivescoreService {
  final Storage _storage;
  final IFixtureApiService _fixtureApiService;
  final NotificationService _notificationService;

  Policy _policy;

  FixtureLivescoreService(
    this._storage,
    this._fixtureApiService,
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
    ).build();
  }

  Future<Tuple2<FixtureFullVm, bool>> loadFixture(int fixtureId) async {
    var currentTeam = await _storage.loadCurrentTeam();

    var fixtureEntity = await _storage.loadFixtureForTeam(
      fixtureId,
      currentTeam.id,
    );

    var shouldSubscribe = false;

    if (!fixtureEntity.isFullyLoaded) {
      try {
        var fixtureDto = await _policy.execute(
          () => _fixtureApiService.getFixtureForTeam(
            fixtureId,
            currentTeam.id,
          ),
        );

        fixtureEntity = FixtureEntity.fromFullDto(currentTeam.id, fixtureDto);

        await _storage.updateFixture(fixtureEntity);

        shouldSubscribe = !fixtureEntity.isFullyLoaded ||
            true; // @@NOTE: Always true for playing around.
      } catch (error) {
        _notificationService.showMessage(error.toString());
      }
    }

    return Tuple2(
      FixtureFullVm.fromEntity(currentTeam, fixtureEntity),
      shouldSubscribe,
    );
  }

  Stream<FixtureFullVm> subscribeToFixture(int fixtureId) async* {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var update$ = await _policy.execute(
        () => _fixtureApiService.subscribeToFixture(
          fixtureId,
          currentTeam.id,
        ),
      );

      await for (var update in update$) {
        try {
          var fixtureEntity = FixtureEntity.fromLivescoreUpdateDto(update);

          fixtureEntity = await _storage.updateFixtureFromLivescore(
            fixtureEntity,
          );

          yield FixtureFullVm.fromEntity(currentTeam, fixtureEntity);
        } catch (_) {}
      }
    } catch (error) {
      _notificationService.showMessage(error.toString());
    }
  }

  void unsubscribeFromFixture(int fixtureId) async {
    var currentTeam = await _storage.loadCurrentTeam();

    await _policy.execute(
      () => _fixtureApiService.unsubscribeFromFixture(
        fixtureId,
        currentTeam.id,
      ),
    );
  }
}
