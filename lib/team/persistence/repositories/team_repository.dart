import 'package:sqflite/sqflite.dart';

import '../../models/entities/team_entity.dart';
import '../tables/team_table.dart';
import '../../interfaces/iteam_repository.dart';
import '../../../general/persistence/db_configurator.dart';

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

    return rows.isNotEmpty ? TeamEntity.fromMap(rows.first) : null;
  }

  Future selectTeam(TeamEntity team) async {
    await _dbConfigurator.ensureOpen();

    await _db.insert(
      TeamTable.tableName,
      team.toMap(true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
