import 'package:flutter/material.dart';

import '../../../common/models/entities/fixture_entity.dart';
import '../../../../general/extensions/color_extension.dart';

class ColorsVm {
  String _homeTeam;
  Color get homeTeam => _homeTeam == null ? null : HexColor.fromHex(_homeTeam);
  String _awayTeam;
  Color get awayTeam => _awayTeam == null ? null : HexColor.fromHex(_awayTeam);

  ColorsVm.fromEntity(FixtureEntity fixture) {
    var teamColor = fixture.colors
        .firstWhere((color) => color.teamId == fixture.teamId)
        .color;
    var opponentTeamColor = fixture.colors
        .firstWhere((color) => color.teamId == fixture.opponentTeamId)
        .color;

    _homeTeam = fixture.homeStatus ? teamColor : opponentTeamColor;
    _awayTeam = fixture.homeStatus ? opponentTeamColor : teamColor;
  }
}
