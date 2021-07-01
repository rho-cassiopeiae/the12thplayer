import 'package:flutter/foundation.dart';

import '../dto/team_dto.dart';

class TeamVm {
  final int id;
  final String name;
  final String logoUrl;

  TeamVm({
    @required this.id,
    @required this.name,
    @required this.logoUrl,
  });

  TeamVm.fromDto(TeamDto team)
      : id = team.id,
        name = team.name,
        logoUrl = team.logoUrl;
}
