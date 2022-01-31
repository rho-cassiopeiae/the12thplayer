import 'package:flutter/foundation.dart';

import '../../../common/models/entities/fixture_entity.dart';

class StatsVm {
  List<StatVm> _stats;
  List<StatVm> get stats => _stats;

  StatsVm.fromEntity(FixtureEntity fixture) {
    var teamStats = fixture.stats
        ?.firstWhere((stats) => stats.teamId == fixture.teamId)
        ?.stats;
    var opponentTeamStats = fixture.stats
        ?.firstWhere((stats) => stats.teamId == fixture.opponentTeamId)
        ?.stats;

    var homeTeamStats = fixture.homeStatus ? teamStats : opponentTeamStats;
    var awayTeamStats = fixture.homeStatus ? opponentTeamStats : teamStats;

    _stats = [];
    if (homeTeamStats != null && awayTeamStats != null) {
      _stats.addAll([
        StatVm(
          name: 'Total Shots',
          homeTeamValue: homeTeamStats.shots?.total ?? 0,
          awayTeamValue: awayTeamStats.shots?.total ?? 0,
        ),
        StatVm(
          name: 'Shots On Target',
          homeTeamValue: homeTeamStats.shots?.onTarget ?? 0,
          awayTeamValue: awayTeamStats.shots?.onTarget ?? 0,
        ),
        StatVm(
          name: 'Shots Inside Box',
          homeTeamValue: homeTeamStats.shots?.insideBox ?? 0,
          awayTeamValue: awayTeamStats.shots?.insideBox ?? 0,
        ),
        StatVm(
          name: 'Shots Outside Box',
          homeTeamValue: homeTeamStats.shots?.outsideBox ?? 0,
          awayTeamValue: awayTeamStats.shots?.outsideBox ?? 0,
        ),
        StatVm(
          name: 'Total Passes',
          homeTeamValue: homeTeamStats.passes?.total ?? 0,
          awayTeamValue: awayTeamStats.passes?.total ?? 0,
        ),
        StatVm(
          name: 'Pass Accuracy',
          homeTeamValue: (homeTeamStats.passes?.total ?? 0) == 0
              ? 0
              : (homeTeamStats.passes?.accurate ?? 0) *
                  100 ~/
                  homeTeamStats.passes.total,
          awayTeamValue: (awayTeamStats.passes?.total ?? 0) == 0
              ? 0
              : (awayTeamStats.passes?.accurate ?? 0) *
                  100 ~/
                  awayTeamStats.passes.total,
          modifier: '%',
        ),
        StatVm(
          name: 'Fouls',
          homeTeamValue: homeTeamStats.fouls ?? 0,
          awayTeamValue: awayTeamStats.fouls ?? 0,
        ),
        StatVm(
          name: 'Corners',
          homeTeamValue: homeTeamStats.corners ?? 0,
          awayTeamValue: awayTeamStats.corners ?? 0,
        ),
        StatVm(
          name: 'Offsides',
          homeTeamValue: homeTeamStats.offsides ?? 0,
          awayTeamValue: awayTeamStats.offsides ?? 0,
        ),
        StatVm(
          name: 'Ball Possession',
          homeTeamValue: homeTeamStats.ballPossession ?? 0,
          awayTeamValue: awayTeamStats.ballPossession ?? 0,
          modifier: '%',
        ),
        StatVm(
          name: 'Yellow Cards',
          homeTeamValue: homeTeamStats.yellowCards ?? 0,
          awayTeamValue: awayTeamStats.yellowCards ?? 0,
        ),
        StatVm(
          name: 'Red Cards',
          homeTeamValue: homeTeamStats.redCards ?? 0,
          awayTeamValue: awayTeamStats.redCards ?? 0,
        ),
        StatVm(
          name: 'Tackles',
          homeTeamValue: homeTeamStats.tackles ?? 0,
          awayTeamValue: awayTeamStats.tackles ?? 0,
        ),
      ]);
    }
  }
}

class StatVm {
  final String name;
  final int homeTeamValue;
  final int awayTeamValue;
  final String modifier;

  StatVm({
    @required this.name,
    @required this.homeTeamValue,
    @required this.awayTeamValue,
    this.modifier = '',
  });
}
