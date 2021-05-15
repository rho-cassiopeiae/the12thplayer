import 'dart:math';

import 'package:either_option/either_option.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../../../general/errors/connection_error.dart';
import '../../../general/errors/server_error.dart';
import '../../../general/utils/policy.dart';
import '../../common/interfaces/ifixture_api_service.dart';
import '../../common/models/entities/fixture_entity.dart';
import '../../common/models/vm/fixture_calendar_vm.dart';
import '../../common/models/vm/fixture_summary_vm.dart';
import '../../../general/persistence/storage.dart';
import '../../../general/errors/error.dart';

class FixtureCalendarService {
  final Storage _storage;
  final IFixtureApiService _fixtureApiService;

  PolicyExecutor2<ConnectionError, ServerError> _apiPolicy;

  FixtureCalendarService(
    this._storage,
    this._fixtureApiService,
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
  }

  Stream<Either<Error, FixtureCalendarVm>> loadFixtures(
    int page,
  ) async* {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      page -= 1000000000;
      var dateOfInterest = Jiffy().add(months: page);
      var firstDay = DateTime(dateOfInterest.year, dateOfInterest.month);
      var lastDay = DateTime(
        dateOfInterest.month < 12
            ? dateOfInterest.year
            : dateOfInterest.year + 1,
        dateOfInterest.month % 12 + 1,
      );

      var fixtureEntities = await _storage.loadFixturesForTeamInBetween(
        currentTeam.id,
        firstDay,
        lastDay,
      );

      int lastResultTime = firstDay.millisecondsSinceEpoch - 1;
      if (fixtureEntities.length > 0) {
        var fixtureVms = fixtureEntities
            .map((fixture) => FixtureSummaryVm.fromEntity(currentTeam, fixture))
            .toList();

        yield Right(
          FixtureCalendarVm(
            year: dateOfInterest.year.toString(),
            month: DateFormat.MMMM().format(dateOfInterest.dateTime),
            fixtures: fixtureVms,
          ),
        );

        var lastFinishedFixture = fixtureEntities.lastWhere(
          (fixture) => fixture.isCompleted,
          orElse: () => null,
        );

        if (lastFinishedFixture != null) {
          if (lastFinishedFixture != fixtureEntities.last) {
            lastResultTime = lastFinishedFixture.startTime;
          } else {
            // @@NOTE: Last finished fixture is the final fixture of the month,
            // meaning, all fixtures of the month have already been fetched and we
            // don't need to get data from the server.
            return;
          }
        }
      }

      var fixtureDtos = await _apiPolicy.execute(
        () => _fixtureApiService.getFixturesForTeamInBetween(
          currentTeam.id,
          lastResultTime,
          lastDay.millisecondsSinceEpoch,
        ),
      );

      if (fixtureDtos.isNotEmpty) {
        fixtureEntities = fixtureDtos.map(
          (fixture) => FixtureEntity.fromSummaryDto(currentTeam.id, fixture),
        );

        await _storage.saveFixtures(fixtureEntities);
      }

      fixtureEntities = await _storage.loadFixturesForTeamInBetween(
        currentTeam.id,
        firstDay,
        lastDay,
      );

      var fixtureVms = fixtureEntities
          .map((fixture) => FixtureSummaryVm.fromEntity(currentTeam, fixture))
          .toList();

      yield Right(
        FixtureCalendarVm(
          year: dateOfInterest.year.toString(),
          month: DateFormat.MMMM().format(dateOfInterest.dateTime),
          fixtures: fixtureVms,
        ),
      );
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      yield Left(Error(error.toString()));
    }
  }
}
