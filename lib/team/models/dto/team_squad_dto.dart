import 'player_dto.dart';
import 'manager_dto.dart';

class TeamSquadDto {
  final int teamId;
  final Iterable<PlayerDto> players;
  final ManagerDto manager;

  TeamSquadDto.fromMap(Map<String, dynamic> map)
      : teamId = map['teamId'],
        players = (map['players'] as List<dynamic>)
            .map((playerMap) => PlayerDto.fromMap(playerMap)),
        manager =
            map['manager'] == null ? null : ManagerDto.fromMap(map['manager']);
}
