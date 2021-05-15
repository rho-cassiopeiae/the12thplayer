import 'package:sqflite/sqflite.dart';

import '../../enums/live_commentary_recording_entry_status.dart';
import '../../enums/live_commentary_recording_status.dart';
import '../../interfaces/ilive_commentary_recording_repository.dart';
import '../../models/entities/live_commentary_recording_entity.dart';
import '../../models/entities/live_commentary_recording_entry_entity.dart';
import '../tables/live_commentary_recording_entry_table.dart';
import '../tables/live_commentary_recording_table.dart';
import '../../../../../general/persistence/db_configurator.dart';

class LiveCommentaryRecordingRepository
    implements ILiveCommentaryRecordingRepository {
  DbConfigurator _dbConfigurator;

  Database get _db => _dbConfigurator.db;

  LiveCommentaryRecordingRepository(this._dbConfigurator);

  @override
  Future<LiveCommentaryRecordingEntity> loadLiveCommentaryRecordingOfFixture(
    int fixtureId,
    int teamId,
  ) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.rawQuery(
          '''
            SELECT
              l.${LiveCommentaryRecordingTable.fixtureId} AS ${LiveCommentaryRecordingTable.fixtureId},
              l.${LiveCommentaryRecordingTable.teamId} AS ${LiveCommentaryRecordingTable.teamId},
              l.${LiveCommentaryRecordingTable.name} AS ${LiveCommentaryRecordingTable.name},
              l.${LiveCommentaryRecordingTable.creationStatus} AS ${LiveCommentaryRecordingTable.creationStatus},
              e.${LiveCommentaryRecordingEntryTable.postedAt} AS ${LiveCommentaryRecordingEntryTable.postedAt},
              e.${LiveCommentaryRecordingEntryTable.time} AS ${LiveCommentaryRecordingEntryTable.time},
              e.${LiveCommentaryRecordingEntryTable.icon} AS ${LiveCommentaryRecordingEntryTable.icon},
              e.${LiveCommentaryRecordingEntryTable.title} AS ${LiveCommentaryRecordingEntryTable.title},
              e.${LiveCommentaryRecordingEntryTable.body} AS ${LiveCommentaryRecordingEntryTable.body},
              e.${LiveCommentaryRecordingEntryTable.imagePath} AS ${LiveCommentaryRecordingEntryTable.imagePath},
              e.${LiveCommentaryRecordingEntryTable.status} AS ${LiveCommentaryRecordingEntryTable.status}
            FROM
              ${LiveCommentaryRecordingTable.tableName} l
              LEFT JOIN
              ${LiveCommentaryRecordingEntryTable.tableName} e
                ON (
                  l.${LiveCommentaryRecordingTable.fixtureId} = e.${LiveCommentaryRecordingEntryTable.fixtureId}
                  AND
                  l.${LiveCommentaryRecordingTable.teamId} = e.${LiveCommentaryRecordingEntryTable.teamId}
                )
            WHERE l.${LiveCommentaryRecordingTable.fixtureId} = ? AND l.${LiveCommentaryRecordingTable.teamId} = ?
            ORDER BY e.${LiveCommentaryRecordingEntryTable.postedAt} DESC;
          ''',
          [fixtureId, teamId],
        );

        LiveCommentaryRecordingEntity recording;
        if (rows.isNotEmpty) {
          Iterable<LiveCommentaryRecordingEntryEntity> entries = [];
          if (rows.first[LiveCommentaryRecordingEntryTable.postedAt] != null) {
            entries = rows.map(
              (row) => LiveCommentaryRecordingEntryEntity.fromMap(row),
            );
          }
          recording =
              LiveCommentaryRecordingEntity.fromMap(rows.first, entries);
        } else {
          recording = LiveCommentaryRecordingEntity.noEntries(
            fixtureId: fixtureId,
            teamId: teamId,
            name: 'Live commentary',
            creationStatus: LiveCommentaryRecordingStatus.None,
          );

          await txn.insert(
            LiveCommentaryRecordingTable.tableName,
            recording.toMap(),
          );
        }

        return recording;
      },
      exclusive: true,
    );
  }

  @override
  Future renameLiveCommentaryRecordingOfFixture(
    int fixtureId,
    int teamId,
    String name,
  ) async {
    await _dbConfigurator.ensureOpen();

    await _db.update(
      LiveCommentaryRecordingTable.tableName,
      {
        LiveCommentaryRecordingTable.name: name,
      },
      where:
          '${LiveCommentaryRecordingTable.fixtureId} = ? AND ${LiveCommentaryRecordingTable.teamId} = ?',
      whereArgs: [fixtureId, teamId],
    );
  }

  @override
  Future<LiveCommentaryRecordingEntity>
      loadLiveCommentaryRecordingNameAndStatus(
    int fixtureId,
    int teamId,
  ) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          LiveCommentaryRecordingTable.tableName,
          columns: [
            LiveCommentaryRecordingTable.name,
            LiveCommentaryRecordingTable.creationStatus,
          ],
          where:
              '${LiveCommentaryRecordingTable.fixtureId} = ? AND ${LiveCommentaryRecordingTable.teamId} = ?',
          whereArgs: [fixtureId, teamId],
        );

        var recording = LiveCommentaryRecordingEntity.fromMap(rows.first, null);

        if (recording.creationStatus == LiveCommentaryRecordingStatus.None) {
          await txn.update(
            LiveCommentaryRecordingTable.tableName,
            {
              LiveCommentaryRecordingTable.creationStatus:
                  LiveCommentaryRecordingStatus.Creating.index,
            },
            where:
                '${LiveCommentaryRecordingTable.fixtureId} = ? AND ${LiveCommentaryRecordingTable.teamId} = ?',
            whereArgs: [fixtureId, teamId],
          );
        }

        return recording;
      },
      exclusive: true,
    );
  }

  @override
  Future updateLiveCommentaryRecordingStatus(
    int fixtureId,
    int teamId,
    LiveCommentaryRecordingStatus status,
  ) async {
    await _dbConfigurator.ensureOpen();

    await _db.update(
      LiveCommentaryRecordingTable.tableName,
      {
        LiveCommentaryRecordingTable.creationStatus: status.index,
      },
      where:
          '${LiveCommentaryRecordingTable.fixtureId} = ? AND ${LiveCommentaryRecordingTable.teamId} = ?',
      whereArgs: [fixtureId, teamId],
    );
  }

  @override
  Future addLiveCommentaryRecordingEntry(
    LiveCommentaryRecordingEntryEntity entry,
  ) async {
    await _dbConfigurator.ensureOpen();

    await _db.insert(
      LiveCommentaryRecordingEntryTable.tableName,
      entry.toMap(),
    );
  }

  @override
  Future<Iterable<LiveCommentaryRecordingEntryEntity>>
      loadLiveCommentaryRecordingEntries(
    int fixtureId,
    int teamId,
  ) async {
    await _dbConfigurator.ensureOpen();

    List<Map<String, dynamic>> rows = await _db.query(
      LiveCommentaryRecordingEntryTable.tableName,
      where:
          '${LiveCommentaryRecordingEntryTable.fixtureId} = ? AND ${LiveCommentaryRecordingEntryTable.teamId} = ?',
      whereArgs: [fixtureId, teamId],
      orderBy: '${LiveCommentaryRecordingEntryTable.postedAt} DESC',
    );

    return rows.map(
      (row) => LiveCommentaryRecordingEntryEntity.fromMap(row),
    );
  }

  @override
  Future updateLiveCommentaryRecordingEntry(
    LiveCommentaryRecordingEntryEntity entry,
  ) async {
    await _dbConfigurator.ensureOpen();

    await _db.update(
      LiveCommentaryRecordingEntryTable.tableName,
      entry.toMap()
        ..remove(LiveCommentaryRecordingEntryTable.fixtureId)
        ..remove(LiveCommentaryRecordingEntryTable.teamId)
        ..remove(LiveCommentaryRecordingEntryTable.postedAt),
      where:
          '${LiveCommentaryRecordingEntryTable.fixtureId} = ? AND ${LiveCommentaryRecordingEntryTable.teamId} = ? AND ${LiveCommentaryRecordingEntryTable.postedAt} = ?',
      whereArgs: [entry.fixtureId, entry.teamId, entry.postedAt],
    );
  }

  @override
  Future<LiveCommentaryRecordingEntryStatus>
      loadPrevLiveCommentaryRecordingEntryStatus(
    int fixtureId,
    int teamId,
    int currentEntryPostedAt,
  ) async {
    await _dbConfigurator.ensureOpen();

    List<Map<String, dynamic>> rows = await _db.query(
      LiveCommentaryRecordingEntryTable.tableName,
      columns: [LiveCommentaryRecordingEntryTable.status],
      where:
          '${LiveCommentaryRecordingEntryTable.fixtureId} = ? AND ${LiveCommentaryRecordingEntryTable.teamId} = ? AND ${LiveCommentaryRecordingEntryTable.postedAt} < ?',
      whereArgs: [fixtureId, teamId, currentEntryPostedAt],
      orderBy: '${LiveCommentaryRecordingEntryTable.postedAt} DESC',
      limit: 1,
    );

    return rows.isNotEmpty
        ? LiveCommentaryRecordingEntryStatus
            .values[rows.first[LiveCommentaryRecordingEntryTable.status]]
        : null;
  }

  @override
  Future<Iterable<LiveCommentaryRecordingEntryEntity>>
      loadNotPublishedLiveCommentaryRecordingEntries(
    int fixtureId,
    int teamId,
  ) async {
    await _dbConfigurator.ensureOpen();

    return await _db.transaction(
      (txn) async {
        List<Map<String, dynamic>> rows = await txn.query(
          LiveCommentaryRecordingEntryTable.tableName, // must load all columns
          where:
              '${LiveCommentaryRecordingEntryTable.fixtureId} = ? AND ${LiveCommentaryRecordingEntryTable.teamId} = ? AND ${LiveCommentaryRecordingEntryTable.status} = ?',
          whereArgs: [
            fixtureId,
            teamId,
            LiveCommentaryRecordingEntryStatus.None.index,
          ],
          orderBy: '${LiveCommentaryRecordingEntryTable.postedAt} ASC',
        );

        var entries = rows.map(
          (row) => LiveCommentaryRecordingEntryEntity.fromMap(row),
        );

        if (entries.isNotEmpty) {
          var batch = txn.batch();

          entries.forEach((entry) {
            batch.update(
              LiveCommentaryRecordingEntryTable.tableName,
              {
                LiveCommentaryRecordingEntryTable.status:
                    LiveCommentaryRecordingEntryStatus.Publishing.index,
              },
              where:
                  '${LiveCommentaryRecordingEntryTable.fixtureId} = ? AND ${LiveCommentaryRecordingEntryTable.teamId} = ? AND ${LiveCommentaryRecordingEntryTable.postedAt} = ?',
              whereArgs: [fixtureId, teamId, entry.postedAt],
            );
          });

          await batch.commit(noResult: true);
        }

        return entries;
      },
      exclusive: true,
    );
  }

  @override
  Future updateLiveCommentaryRecordingEntries(
    Iterable<LiveCommentaryRecordingEntryEntity> entries,
  ) async {
    await _dbConfigurator.ensureOpen();

    var batch = _db.batch();

    entries.forEach((entry) {
      batch.update(
        LiveCommentaryRecordingEntryTable.tableName,
        entry.toMap()
          ..remove(LiveCommentaryRecordingEntryTable.fixtureId)
          ..remove(LiveCommentaryRecordingEntryTable.teamId)
          ..remove(LiveCommentaryRecordingEntryTable.postedAt),
        where:
            '${LiveCommentaryRecordingEntryTable.fixtureId} = ? AND ${LiveCommentaryRecordingEntryTable.teamId} = ? AND ${LiveCommentaryRecordingEntryTable.postedAt} = ?',
        whereArgs: [entry.fixtureId, entry.teamId, entry.postedAt],
      );
    });

    await batch.commit(noResult: true);
  }
}
