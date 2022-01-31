import 'dart:convert';

import '../../../livescore/models/dto/fixture_livescore_update_dto.dart';
import '../../../livescore/models/dto/fixture_full_dto.dart';
import '../../persistence/tables/fixture_table.dart';
import '../dto/fixture_summary_dto.dart';
import 'team_color_entity.dart';
import 'game_time_entity.dart';
import 'score_entity.dart';
import 'team_stats_entity.dart';
import 'team_lineup_entity.dart';
import 'team_match_events_entity.dart';
import '../../../../general/extensions/map_extension.dart';

class FixtureEntity {
  final int id;
  final int teamId;
  final String leagueName;
  final String leagueLogoUrl;
  final int opponentTeamId;
  final String opponentTeamName;
  final String opponentTeamLogoUrl;
  final bool homeStatus;
  final int startTime;
  final String status;
  final GameTimeEntity gameTime;
  final ScoreEntity score;
  final String venueName;
  final String venueImageUrl;
  final String refereeName;
  final List<TeamColorEntity> colors;
  final List<TeamLineupEntity> lineups;
  final List<TeamMatchEventsEntity> events;
  final List<TeamStatsEntity> stats;
  final bool isFullyLoaded;

  bool get isCompleted =>
      status == 'FT' || status == 'AET' || status == 'FT_PEN';

  Iterable<PlayerEntity> get allPlayers {
    var players = <PlayerEntity>[];
    if (lineups != null) {
      players.addAll(lineups[0].startingXI);
      players.addAll(lineups[0].subs);
      players.addAll(lineups[1].startingXI);
      players.addAll(lineups[1].subs);
    }

    return players;
  }

  Map<String, dynamic> toSummaryMap() {
    var map = Map<String, dynamic>();

    map[FixtureTable.id] = id;
    map[FixtureTable.teamId] = teamId;
    map[FixtureTable.leagueName] = leagueName;
    map[FixtureTable.leagueLogoUrl] = leagueLogoUrl;
    map[FixtureTable.opponentTeamId] = opponentTeamId;
    map[FixtureTable.opponentTeamName] = opponentTeamName;
    map[FixtureTable.opponentTeamLogoUrl] = opponentTeamLogoUrl;
    map[FixtureTable.homeStatus] = homeStatus ? 1 : 0;
    map[FixtureTable.startTime] = startTime;
    map[FixtureTable.status] = status;
    map[FixtureTable.gameTime] = jsonEncode(gameTime);
    map[FixtureTable.score] = jsonEncode(score);
    map[FixtureTable.venueName] = venueName;
    map[FixtureTable.venueImageUrl] = venueImageUrl;
    map[FixtureTable.isFullyLoaded] = isFullyLoaded ? 1 : 0;

    return map;
  }

  Map<String, dynamic> toFullMap() {
    var map = Map<String, dynamic>();

    map[FixtureTable.id] = id;
    map[FixtureTable.teamId] = teamId;
    map[FixtureTable.leagueName] = leagueName;
    map[FixtureTable.leagueLogoUrl] = leagueLogoUrl;
    map[FixtureTable.opponentTeamId] = opponentTeamId;
    map[FixtureTable.opponentTeamName] = opponentTeamName;
    map[FixtureTable.opponentTeamLogoUrl] = opponentTeamLogoUrl;
    map[FixtureTable.homeStatus] = homeStatus ? 1 : 0;
    map[FixtureTable.startTime] = startTime;
    map[FixtureTable.status] = status;
    map[FixtureTable.gameTime] = jsonEncode(gameTime);
    map[FixtureTable.score] = jsonEncode(score);
    map[FixtureTable.venueName] = venueName;
    map[FixtureTable.venueImageUrl] = venueImageUrl;
    map[FixtureTable.refereeName] = refereeName;
    map[FixtureTable.colors] = jsonEncode(colors);
    map[FixtureTable.lineups] = jsonEncode(lineups);
    map[FixtureTable.events] = jsonEncode(events);
    map[FixtureTable.stats] = jsonEncode(stats);
    map[FixtureTable.isFullyLoaded] = isFullyLoaded ? 1 : 0;

    return map;
  }

  Map<String, dynamic> toLivescoreUpdateMap() {
    var map = Map<String, dynamic>();

    map[FixtureTable.id] = id;
    map[FixtureTable.teamId] = teamId;
    if (startTime != null) {
      map[FixtureTable.startTime] = startTime;
    }
    map[FixtureTable.status] = status;
    if (gameTime != null) {
      map[FixtureTable.gameTime] = jsonEncode(gameTime);
    }
    if (score != null) {
      map[FixtureTable.score] = jsonEncode(score);
    }
    if (refereeName != null) {
      map[FixtureTable.refereeName] = refereeName;
    }
    if (colors != null) {
      map[FixtureTable.colors] = jsonEncode(colors);
    }
    if (lineups != null) {
      map[FixtureTable.lineups] = jsonEncode(lineups);
    }
    if (events != null) {
      map[FixtureTable.events] = jsonEncode(events);
    }
    if (stats != null) {
      map[FixtureTable.stats] = jsonEncode(stats);
    }

    return map;
  }

  FixtureEntity.fromMap(Map<String, dynamic> map)
      : id = map.getOrNull(FixtureTable.id),
        teamId = map.getOrNull(FixtureTable.teamId),
        leagueName = map.getOrNull(FixtureTable.leagueName),
        leagueLogoUrl = map.getOrNull(FixtureTable.leagueLogoUrl),
        opponentTeamId = map.getOrNull(FixtureTable.opponentTeamId),
        opponentTeamName = map.getOrNull(FixtureTable.opponentTeamName),
        opponentTeamLogoUrl = map.getOrNull(FixtureTable.opponentTeamLogoUrl),
        homeStatus = !map.containsKey(FixtureTable.homeStatus)
            ? null
            : map[FixtureTable.homeStatus] == 1,
        startTime = map.getOrNull(FixtureTable.startTime),
        status = map.getOrNull(FixtureTable.status),
        gameTime = !map.containsKey(FixtureTable.gameTime)
            ? null
            : GameTimeEntity.fromMap(jsonDecode(map[FixtureTable.gameTime])),
        score = !map.containsKey(FixtureTable.score)
            ? null
            : ScoreEntity.fromMap(jsonDecode(map[FixtureTable.score])),
        venueName = map.getOrNull(FixtureTable.venueName),
        venueImageUrl = map.getOrNull(FixtureTable.venueImageUrl),
        refereeName = map.getOrNull(FixtureTable.refereeName),
        colors = map.notContainsOrNull(FixtureTable.colors)
            ? null
            : (jsonDecode(map[FixtureTable.colors]) as List)
                .map((colorMap) => TeamColorEntity.fromMap(colorMap))
                .toList(),
        lineups = map.notContainsOrNull(FixtureTable.lineups)
            ? null
            : (jsonDecode(map[FixtureTable.lineups]) as List)
                .map((lineupMap) => TeamLineupEntity.fromMap(lineupMap))
                .toList(),
        events = map.notContainsOrNull(FixtureTable.events)
            ? null
            : (jsonDecode(map[FixtureTable.events]) as List)
                .map((eventsMap) => TeamMatchEventsEntity.fromMap(eventsMap))
                .toList(),
        stats = map.notContainsOrNull(FixtureTable.stats)
            ? null
            : (jsonDecode(map[FixtureTable.stats]) as List)
                .map((statsMap) => TeamStatsEntity.fromMap(statsMap))
                .toList(),
        isFullyLoaded = !map.containsKey(FixtureTable.isFullyLoaded)
            ? null
            : map[FixtureTable.isFullyLoaded] == 1;

  FixtureEntity.fromSummaryDto(int teamId, FixtureSummaryDto fixture)
      : id = fixture.id,
        teamId = teamId,
        leagueName = fixture.season.leagueName,
        leagueLogoUrl = fixture.season.leagueLogoUrl,
        opponentTeamId = fixture.opponentTeam.id,
        opponentTeamName = fixture.opponentTeam.name,
        opponentTeamLogoUrl = fixture.opponentTeam.logoUrl,
        homeStatus = fixture.homeStatus,
        startTime = fixture.startTime,
        status = fixture.status,
        gameTime = GameTimeEntity.fromDto(fixture.gameTime),
        score = ScoreEntity.fromDto(fixture.score),
        venueName = fixture.venue.name,
        venueImageUrl = fixture.venue.imageUrl,
        refereeName = null,
        colors = null,
        lineups = null,
        events = null,
        stats = null,
        isFullyLoaded = false;

  FixtureEntity.fromFullDto(int teamId, FixtureFullDto fixture)
      : id = fixture.id,
        teamId = teamId,
        leagueName = fixture.season.leagueName,
        leagueLogoUrl = fixture.season.leagueLogoUrl,
        opponentTeamId = fixture.opponentTeam.id,
        opponentTeamName = fixture.opponentTeam.name,
        opponentTeamLogoUrl = fixture.opponentTeam.logoUrl,
        homeStatus = fixture.homeStatus,
        startTime = fixture.startTime,
        status = fixture.status,
        gameTime = GameTimeEntity.fromDto(fixture.gameTime),
        score = ScoreEntity.fromDto(fixture.score),
        venueName = fixture.venue.name,
        venueImageUrl = fixture.venue.imageUrl,
        refereeName = fixture.refereeName,
        colors = fixture.colors
            .map((color) => TeamColorEntity.fromDto(color))
            .toList(),
        lineups = fixture.lineups
            .map((lineup) => TeamLineupEntity.fromDto(lineup))
            .toList(),
        events = fixture.events
            .map((events) => TeamMatchEventsEntity.fromDto(events))
            .toList(),
        stats = fixture.stats
            .map((stats) => TeamStatsEntity.fromDto(stats))
            .toList(),
        isFullyLoaded = fixture.isCompleted;

  FixtureEntity.fromLivescoreUpdateDto(FixtureLivescoreUpdateDto update)
      : id = update.fixtureId,
        teamId = update.teamId,
        leagueName = null,
        leagueLogoUrl = null,
        opponentTeamId = null,
        opponentTeamName = null,
        opponentTeamLogoUrl = null,
        homeStatus = null,
        startTime = update.startTime,
        status = update.status,
        gameTime = update.gameTime == null
            ? null
            : GameTimeEntity.fromDto(update.gameTime),
        score = update.score == null ? null : ScoreEntity.fromDto(update.score),
        venueName = null,
        venueImageUrl = null,
        refereeName = update.refereeName,
        colors = update.colors
            ?.map((color) => TeamColorEntity.fromDto(color))
            ?.toList(),
        lineups = update.lineups
            ?.map((lineup) => TeamLineupEntity.fromDto(lineup))
            ?.toList(),
        events = update.events
            ?.map((events) => TeamMatchEventsEntity.fromDto(events))
            ?.toList(),
        stats = update.stats
            ?.map((stats) => TeamStatsEntity.fromDto(stats))
            ?.toList(),
        isFullyLoaded = null;
}
