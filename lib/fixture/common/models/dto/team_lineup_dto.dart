class TeamLineupDto {
  final int teamId;
  final String formation;
  final ManagerDto manager;
  final Iterable<PlayerDto> startingXI;
  final Iterable<PlayerDto> subs;

  TeamLineupDto.fromMap(Map<String, dynamic> map)
      : teamId = map['teamId'],
        formation = map['formation'],
        manager =
            map['manager'] == null ? null : ManagerDto.fromMap(map['manager']),
        startingXI = (map['startingXI'] as List)
            .map((playerMap) => PlayerDto.fromMap(playerMap)),
        subs = (map['subs'] as List)
            .map((playerMap) => PlayerDto.fromMap(playerMap));
}

class PlayerDto {
  final int id;
  final String firstName;
  final String lastName;
  final String displayName;
  final int number;
  final bool isCaptain;
  final String position;
  final int formationPosition;
  final String imageUrl;

  PlayerDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        firstName = map['firstName'],
        lastName = map['lastName'],
        displayName = map['displayName'],
        number = map['number'],
        isCaptain = map['isCaptain'],
        position = map['position'],
        formationPosition = map['formationPosition'],
        imageUrl = map['imageUrl'];
}

class ManagerDto {
  final int id;
  final String name;
  final String imageUrl;

  ManagerDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        imageUrl = map['imageUrl'];
}
