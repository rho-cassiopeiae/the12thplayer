import 'dart:math';

import 'package:either_option/either_option.dart';

import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../../general/utils/policy.dart';
import '../models/vm/fixture_performance_rating_vm.dart';
import '../models/vm/team_squad_vm.dart';
import '../../general/errors/error.dart';
import '../../general/persistence/storage.dart';
import '../interfaces/iteam_api_service.dart';

class TeamService {
  final Storage _storage;
  final ITeamApiService _teamApiService;

  PolicyExecutor2<ConnectionError, ServerError> _apiPolicy;

  TeamService(this._storage, this._teamApiService) {
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

  Future<Either<Error, TeamSquadVm>> loadTeamSquad() async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var teamSquad = await _apiPolicy.execute(
        () => _teamApiService.getTeamSquad(currentTeam.id),
      );

      return Right(TeamSquadVm.fromDto(teamSquad));
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Future<Either<Error, List<FixturePerformanceRatingVm>>>
      loadPlayerPerformanceRatings(
    int playerId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var performanceRatings = await _apiPolicy.execute(
        () => _teamApiService.getTeamPlayerPerformanceRatings(
          currentTeam.id,
          playerId,
        ),
      );

      return Right(
        performanceRatings
            .map((rating) => FixturePerformanceRatingVm.fromDto(rating))
            .toList(),
      );
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Future<Either<Error, List<FixturePerformanceRatingVm>>>
      loadManagerPerformanceRatings(
    int managerId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var performanceRatings = await _apiPolicy.execute(
        () => _teamApiService.getTeamManagerPerformanceRatings(
          currentTeam.id,
          managerId,
        ),
      );

      return Right(
        performanceRatings
            .map((rating) => FixturePerformanceRatingVm.fromDto(rating))
            .toList(),
      );
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }
}
