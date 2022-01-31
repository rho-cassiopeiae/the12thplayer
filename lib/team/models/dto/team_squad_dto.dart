import 'player_dto.dart';
import 'manager_dto.dart';

class TeamSquadDto {
  final ManagerDto manager;
  final Iterable<PlayerDto> players;

  TeamSquadDto.fromMap(Map<String, dynamic> map)
      : manager =
            map['manager'] == null ? null : ManagerDto.fromMap(map['manager']),
        players = (map['players'] as List)
            .map((playerMap) => PlayerDto.fromMap(playerMap));
}
