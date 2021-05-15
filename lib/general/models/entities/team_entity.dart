import '../../persistence/tables/team_table.dart';

class TeamEntity {
  final int id;
  final String name;
  final String logoUrl;

  TeamEntity.fromMap(Map<String, dynamic> map)
      : id = map[TeamTable.id],
        name = map[TeamTable.name],
        logoUrl = map[TeamTable.logoUrl];
}
