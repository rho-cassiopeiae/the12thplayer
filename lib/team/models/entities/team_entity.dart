import 'package:flutter/foundation.dart';

import '../../persistence/tables/team_table.dart';

class TeamEntity {
  final int id;
  final String name;
  final String logoUrl;

  TeamEntity({
    @required this.id,
    @required this.name,
    @required this.logoUrl,
  });

  TeamEntity.fromMap(Map<String, dynamic> map)
      : id = map[TeamTable.id],
        name = map[TeamTable.name],
        logoUrl = map[TeamTable.logoUrl];

  Map<String, dynamic> toMap(bool currentlySelected) {
    var map = Map<String, dynamic>();

    map[TeamTable.id] = id;
    map[TeamTable.name] = name;
    map[TeamTable.logoUrl] = logoUrl;
    map[TeamTable.currentlySelected] = currentlySelected ? 1 : 0;

    return map;
  }
}
