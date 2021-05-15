import 'package:sqflite/sqflite.dart';

import '../../models/entities/team_entity.dart';
import '../tables/team_table.dart';
import '../../interfaces/iteam_repository.dart';
import '../db_configurator.dart';

class TeamRepository implements ITeamRepository {
  DbConfigurator _dbConfigurator;

  Database get _db => _dbConfigurator.db;

  TeamRepository(this._dbConfigurator);

  @override
  Future<TeamEntity> loadCurrentTeam() async {
    await _dbConfigurator.ensureOpen();

    List<Map<String, dynamic>> rows = await _db.query(
      TeamTable.tableName,
      columns: [
        TeamTable.id,
        TeamTable.name,
        TeamTable.logoUrl,
      ],
      where: '${TeamTable.currentlySelected} = ?',
      whereArgs: [1],
    );

    return TeamEntity.fromMap(rows.first);
  }
}
