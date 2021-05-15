import '../dto/team_lineup_dto.dart';

class TeamLineupEntity {
  final int teamId;
  final String formation;
  final ManagerEntity manager;
  final List<PlayerEntity> startingXI;
  final List<PlayerEntity> subs;

  TeamLineupEntity.fromMap(Map<String, dynamic> map)
      : teamId = map['teamId'],
        formation = map['formation'],
        manager = map['manager'] == null
            ? null
            : ManagerEntity.fromMap(map['manager']),
        startingXI = map['startingXI'] == null
            ? null
            : (map['startingXI'] as List<dynamic>)
                .map((playerMap) => PlayerEntity.fromMap(playerMap))
                .toList(),
        subs = map['subs'] == null
            ? null
            : (map['subs'] as List<dynamic>)
                .map((playerMap) => PlayerEntity.fromMap(playerMap))
                .toList();

  TeamLineupEntity.fromDto(TeamLineupDto lineup)
      : teamId = lineup.teamId,
        formation = lineup.formation,
        manager = lineup.manager == null
            ? null
            : ManagerEntity.fromDto(lineup.manager),
        startingXI = lineup.startingXI
            ?.map((player) => PlayerEntity.fromDto(player))
            ?.toList(),
        subs = lineup.subs
            ?.map((player) => PlayerEntity.fromDto(player))
            ?.toList();

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['teamId'] = teamId;
    map['formation'] = formation;
    map['manager'] = manager?.toJson();
    map['startingXI'] = startingXI?.map((player) => player.toJson())?.toList();
    map['subs'] = subs?.map((player) => player.toJson())?.toList();

    return map;
  }
}

class PlayerEntity {
  final int id;
  final String name;
  final int number;
  final bool isCaptain;
  final String position;
  final int formationPosition;
  final String imageUrl;

  PlayerEntity.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        number = map['number'],
        isCaptain = map['isCaptain'],
        position = map['position'],
        formationPosition = map['formationPosition'],
        imageUrl = map['imageUrl'];

  PlayerEntity.fromDto(PlayerDto player)
      : id = player.id,
        name = player.name,
        number = player.number,
        isCaptain = player.isCaptain,
        position = player.position,
        formationPosition = player.formationPosition,
        imageUrl = player.imageUrl;

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['id'] = id;
    map['name'] = name;
    map['number'] = number;
    map['isCaptain'] = isCaptain;
    map['position'] = position;
    map['formationPosition'] = formationPosition;
    map['imageUrl'] = imageUrl;

    return map;
  }
}

class ManagerEntity {
  final int id;
  final String name;
  final String imageUrl;

  ManagerEntity.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        imageUrl = map['imageUrl'];

  ManagerEntity.fromDto(ManagerDto manager)
      : id = manager.id,
        name = manager.name,
        imageUrl = manager.imageUrl;

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['id'] = id;
    map['name'] = name;
    map['imageUrl'] = imageUrl;

    return map;
  }
}
