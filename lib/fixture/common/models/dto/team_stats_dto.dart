class TeamStatsDto {
  final int teamId;
  final StatsDto stats;

  TeamStatsDto.fromMap(Map<String, dynamic> map)
      : teamId = map['teamId'],
        stats = map['stats'] == null ? null : StatsDto.fromMap(map['stats']);
}

class StatsDto {
  final ShotStatsDto shots;
  final PassStatsDto passes;
  final int fouls;
  final int corners;
  final int offsides;
  final int ballPossession;
  final int yellowCards;
  final int redCards;
  final int tackles;

  StatsDto.fromMap(Map<String, dynamic> map)
      : shots =
            map['shots'] == null ? null : ShotStatsDto.fromMap(map['shots']),
        passes =
            map['passes'] == null ? null : PassStatsDto.fromMap(map['passes']),
        fouls = map['fouls'],
        corners = map['corners'],
        offsides = map['offsides'],
        ballPossession = map['ballPossession'],
        yellowCards = map['yellowCards'],
        redCards = map['redCards'],
        tackles = map['tackles'];
}

class ShotStatsDto {
  final int total;
  final int onTarget;
  final int offTarget;
  final int blocked;
  final int insideBox;
  final int outsideBox;

  ShotStatsDto.fromMap(Map<String, dynamic> map)
      : total = map['total'],
        onTarget = map['onTarget'],
        offTarget = map['offTarget'],
        blocked = map['blocked'],
        insideBox = map['insideBox'],
        outsideBox = map['outsideBox'];
}

class PassStatsDto {
  final int total;
  final int accurate;

  PassStatsDto.fromMap(Map<String, dynamic> map)
      : total = map['total'],
        accurate = map['accurate'];
}
