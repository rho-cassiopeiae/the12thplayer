import '../dto/team_stats_dto.dart';

class TeamStatsEntity {
  final int teamId;
  final StatsEntity stats;

  TeamStatsEntity.fromMap(Map<String, dynamic> map)
      : teamId = map['teamId'],
        stats = map['stats'] == null ? null : StatsEntity.fromMap(map['stats']);

  TeamStatsEntity.fromDto(TeamStatsDto stats)
      : teamId = stats.teamId,
        stats = stats.stats == null ? null : StatsEntity.fromDto(stats.stats);

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['teamId'] = teamId;
    map['stats'] = stats?.toJson();

    return map;
  }
}

class StatsEntity {
  final ShotStatsEntity shots;
  final PassStatsEntity passes;
  final int fouls;
  final int corners;
  final int offsides;
  final int ballPossession;
  final int yellowCards;
  final int redCards;
  final int tackles;

  StatsEntity.fromMap(Map<String, dynamic> map)
      : shots =
            map['shots'] == null ? null : ShotStatsEntity.fromMap(map['shots']),
        passes = map['passes'] == null
            ? null
            : PassStatsEntity.fromMap(map['passes']),
        fouls = map['fouls'],
        corners = map['corners'],
        offsides = map['offsides'],
        ballPossession = map['ballPossession'],
        yellowCards = map['yellowCards'],
        redCards = map['redCards'],
        tackles = map['tackles'];

  StatsEntity.fromDto(StatsDto stats)
      : shots =
            stats.shots == null ? null : ShotStatsEntity.fromDto(stats.shots),
        passes =
            stats.passes == null ? null : PassStatsEntity.fromDto(stats.passes),
        fouls = stats.fouls,
        corners = stats.corners,
        offsides = stats.offsides,
        ballPossession = stats.ballPossession,
        yellowCards = stats.yellowCards,
        redCards = stats.redCards,
        tackles = stats.tackles;

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['shots'] = shots?.toJson();
    map['passes'] = passes?.toJson();
    map['fouls'] = fouls;
    map['corners'] = corners;
    map['offsides'] = offsides;
    map['ballPossession'] = ballPossession;
    map['yellowCards'] = yellowCards;
    map['redCards'] = redCards;
    map['tackles'] = tackles;

    return map;
  }
}

class ShotStatsEntity {
  final int total;
  final int onTarget;
  final int offTarget;
  final int blocked;
  final int insideBox;
  final int outsideBox;

  ShotStatsEntity.fromMap(Map<String, dynamic> map)
      : total = map['total'],
        onTarget = map['onTarget'],
        offTarget = map['offTarget'],
        blocked = map['blocked'],
        insideBox = map['insideBox'],
        outsideBox = map['outsideBox'];

  ShotStatsEntity.fromDto(ShotStatsDto stats)
      : total = stats.total,
        onTarget = stats.onTarget,
        offTarget = stats.offTarget,
        blocked = stats.blocked,
        insideBox = stats.insideBox,
        outsideBox = stats.outsideBox;

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['total'] = total;
    map['onTarget'] = onTarget;
    map['offTarget'] = offTarget;
    map['blocked'] = blocked;
    map['insideBox'] = insideBox;
    map['outsideBox'] = outsideBox;

    return map;
  }
}

class PassStatsEntity {
  final int total;
  final int accurate;

  PassStatsEntity.fromMap(Map<String, dynamic> map)
      : total = map['total'],
        accurate = map['accurate'];

  PassStatsEntity.fromDto(PassStatsDto stats)
      : total = stats.total,
        accurate = stats.accurate;

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['total'] = total;
    map['accurate'] = accurate;

    return map;
  }
}
