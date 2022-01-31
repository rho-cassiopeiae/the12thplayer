import 'package:flutter/foundation.dart';

import '../../../common/models/entities/fixture_entity.dart';
import '../../../common/models/entities/team_lineup_entity.dart';
import '../../data/formation_to_positions.dart';

class LineupsVm {
  LineupVm _homeTeam;
  LineupVm get homeTeam => _homeTeam;
  LineupVm _awayTeam;
  LineupVm get awayTeam => _awayTeam;

  LineupsVm.fromEntity(FixtureEntity fixture) {
    var teamLineup = LineupVm.fromEntity(
      fixture.lineups?.firstWhere(
        (lineup) => lineup.teamId == fixture.teamId,
      ),
    );
    var opponentTeamLineup = LineupVm.fromEntity(
      fixture.lineups?.firstWhere(
        (lineup) => lineup.teamId == fixture.opponentTeamId,
      ),
    );

    _homeTeam = fixture.homeStatus ? teamLineup : opponentTeamLineup;
    _awayTeam = fixture.homeStatus ? opponentTeamLineup : teamLineup;
  }
}

class LineupVm {
  final String formation;
  final ManagerVm manager;
  final List<PlayerVm> startingXI;
  final List<PlayerVm> subs;

  bool _canDrawFormation;
  bool get canDrawFormation => _canDrawFormation;

  LineupVm.fromEntity(TeamLineupEntity lineup)
      : formation = lineup?.formation,
        manager = lineup?.manager != null
            ? ManagerVm.fromEntity(lineup.manager)
            : null,
        startingXI = lineup != null
            ? lineup.startingXI
                .map((player) => PlayerVm.fromEntity(lineup.formation, player))
                .toList()
            : [],
        subs = lineup != null
            ? lineup.subs
                .map((player) => PlayerVm.fromEntity(lineup.formation, player))
                .toList()
            : [] {
    _canDrawFormation = startingXI.length == 11 &&
        startingXI.every((player) => player.formationPosition != null);

    startingXI.sort(
      (p1, p2) => _positionToPriority[p1.position].compareTo(
        _positionToPriority[p2.position],
      ),
    );

    subs.sort(
      (p1, p2) => _positionToPriority[p1.position].compareTo(
        _positionToPriority[p2.position],
      ),
    );
  }
}

class PlayerVm {
  final String displayName;
  final int number;
  final bool isCaptain;
  final String position;
  FormationPositionVm _formationPosition;
  FormationPositionVm get formationPosition => _formationPosition;
  final String imageUrl;

  PlayerVm.fromEntity(String formation, PlayerEntity player)
      : displayName = player.getDisplayName(),
        number = player.number,
        isCaptain = player.isCaptain,
        position = player.position,
        imageUrl = player.imageUrl {
    if (formation != null &&
        player.formationPosition != null &&
        formationToPositions.containsKey(formation)) {
      var chosenFormation = formationToPositions[formation];
      var positionKey = player.formationPosition.toString();
      if (chosenFormation.containsKey(positionKey)) {
        var position = chosenFormation[positionKey];
        _formationPosition = FormationPositionVm(
          top: position['top'],
          left: position.containsKey('left') ? position['left'] : null,
          right: position.containsKey('right') ? position['right'] : null,
          radius: (position.containsKey('radius') ? position['radius'] : 22)
              .toDouble(),
        );
      }
    }
  }
}

class FormationPositionVm {
  final int top;
  final int left;
  final int right;
  final double radius;

  FormationPositionVm({
    @required this.top,
    @required this.left,
    @required this.right,
    @required this.radius,
  });
}

class ManagerVm {
  final String name;
  final String imageUrl;

  ManagerVm.fromEntity(ManagerEntity manager)
      : name = manager.name,
        imageUrl = manager.imageUrl;
}

var _positionToPriority = {
  'G': 1,
  'D': 2,
  'M': 3,
  'A': 4,
  null: 5,
};
