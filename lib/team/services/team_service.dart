import 'dart:math';

import '../../general/services/notification_service.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../../general/utils/policy.dart';
import '../models/vm/fixture_player_rating_vm.dart';
import '../models/vm/team_squad_vm.dart';
import '../../general/persistence/storage.dart';
import '../interfaces/iteam_api_service.dart';

class TeamService {
  final Storage _storage;
  final ITeamApiService _teamApiService;
  final NotificationService _notificationService;

  Policy _policy;

  TeamService(
    this._storage,
    this._teamApiService,
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

  Future<TeamSquadVm> loadTeamSquad() async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var teamSquad = await _policy.execute(
        () => _teamApiService.getTeamSquad(currentTeam.id),
      );

      return TeamSquadVm.fromDto(teamSquad);
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return null;
    }
  }

  Future<List<FixturePlayerRatingVm>> loadPlayerRatings(
    int playerId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var playerRatings = await _policy.execute(
        () => _teamApiService.getTeamPlayerRatings(
          currentTeam.id,
          playerId,
        ),
      );

      return playerRatings
          .map((rating) => FixturePlayerRatingVm.fromDto(rating))
          .toList();
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return null;
    }
  }

  Future<List<FixturePlayerRatingVm>> loadManagerRatings(
    int managerId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var managerRatings = await _policy.execute(
        () => _teamApiService.getTeamManagerRatings(
          currentTeam.id,
          managerId,
        ),
      );

      return managerRatings
          .map((rating) => FixturePlayerRatingVm.fromDto(rating))
          .toList();
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return null;
    }
  }
}
