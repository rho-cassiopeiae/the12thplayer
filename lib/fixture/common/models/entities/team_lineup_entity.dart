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
        startingXI = (map['startingXI'] as List)
            .map((playerMap) => PlayerEntity.fromMap(playerMap))
            .toList(),
        subs = (map['subs'] as List)
            .map((playerMap) => PlayerEntity.fromMap(playerMap))
            .toList();

  TeamLineupEntity.fromDto(TeamLineupDto lineup)
      : teamId = lineup.teamId,
        formation = lineup.formation,
        manager = lineup.manager == null
            ? null
            : ManagerEntity.fromDto(lineup.manager),
        startingXI = lineup.startingXI
            .map((player) => PlayerEntity.fromDto(player))
            .toList(),
        subs =
            lineup.subs.map((player) => PlayerEntity.fromDto(player)).toList();

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['teamId'] = teamId;
    map['formation'] = formation;
    map['manager'] = manager?.toJson();
    map['startingXI'] = startingXI.map((player) => player.toJson()).toList();
    map['subs'] = subs.map((player) => player.toJson()).toList();

    return map;
  }
}

class PlayerEntity {
  final int id;
  final String firstName;
  final String lastName;
  final String displayName;
  final int number;
  final bool isCaptain;
  final String position;
  final int formationPosition;
  final String imageUrl;

  PlayerEntity.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        firstName = map['firstName'],
        lastName = map['lastName'],
        displayName = map['displayName'],
        number = map['number'],
        isCaptain = map['isCaptain'],
        position = map['position'],
        formationPosition = map['formationPosition'],
        imageUrl = map['imageUrl'];

  PlayerEntity.fromDto(PlayerDto player)
      : id = player.id,
        firstName = player.firstName,
        lastName = player.lastName,
        displayName = player.displayName,
        number = player.number,
        isCaptain = player.isCaptain,
        position = player.position,
        formationPosition = player.formationPosition,
        imageUrl = player.imageUrl;

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['id'] = id;
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['displayName'] = displayName;
    map['number'] = number;
    map['isCaptain'] = isCaptain;
    map['position'] = position;
    map['formationPosition'] = formationPosition;
    map['imageUrl'] = imageUrl;

    return map;
  }

  String getDisplayName() {
    int maxLength = 14;

    if (displayName != null && displayName.length <= maxLength) {
      return displayName;
    }
    if (firstName == null && lastName != null && lastName.length <= maxLength) {
      return lastName;
    }
    if (lastName == null &&
        firstName != null &&
        firstName.length <= maxLength) {
      return firstName;
    }

    var displayNameSplit = displayName.split(' ');
    if (displayNameSplit.length == 1) {
      return displayName;
    }

    // Ruud van Nistelrooy | R. van Nistelrooy | R.v. Nistelrooy
    var buffer = StringBuffer();
    for (int i = 0; i < displayNameSplit.length - 1; ++i) {
      buffer.clear();
      for (int j = 0; j <= i; ++j) {
        buffer.write(displayNameSplit[j].substring(0, 1));
        buffer.write('.');
      }
      for (int j = i + 1; j < displayNameSplit.length; ++j) {
        buffer.write(' ');
        buffer.write(displayNameSplit[j]);
      }

      var name = buffer.toString();
      if (name.length <= maxLength) {
        return name;
      }
    }

    return buffer.toString();
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
