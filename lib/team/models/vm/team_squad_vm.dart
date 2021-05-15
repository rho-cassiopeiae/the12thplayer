import '../dto/team_squad_dto.dart';
import 'manager_vm.dart';
import 'player_vm.dart';

class TeamSquadVm {
  final ManagerVm manager;
  List<PlayerVm> _goalkeepers;
  List<PlayerVm> get goalkeepers => _goalkeepers;
  List<PlayerVm> _defenders;
  List<PlayerVm> get defenders => _defenders;
  List<PlayerVm> _midfielders;
  List<PlayerVm> get midfielders => _midfielders;
  List<PlayerVm> _attackers;
  List<PlayerVm> get attackers => _attackers;

  TeamSquadVm.fromDto(TeamSquadDto teamSquad)
      : manager = teamSquad.manager == null
            ? null
            : ManagerVm.fromDto(teamSquad.manager) {
    var players = teamSquad.players.map((player) => PlayerVm.fromDto(player));

    _goalkeepers = players
        .where((player) => player.position == 'Goalkeeper')
        .toList()
          ..sort((p1, p2) => p1.number.compareTo(p2.number));
    _defenders = players
        .where((player) => player.position == 'Defender')
        .toList()
          ..sort((p1, p2) => p1.number.compareTo(p2.number));
    _midfielders = players
        .where((player) => player.position == 'Midfielder')
        .toList()
          ..sort((p1, p2) => p1.number.compareTo(p2.number));
    _attackers = players
        .where((player) => player.position == 'Attacker')
        .toList()
          ..sort((p1, p2) => p1.number.compareTo(p2.number));
  }
}
