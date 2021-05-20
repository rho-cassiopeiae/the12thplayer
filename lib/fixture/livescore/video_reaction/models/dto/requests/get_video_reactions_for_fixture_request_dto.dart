import 'package:flutter/foundation.dart';

import '../../../enums/video_reaction_filter.dart';

class GetVideoReactionsForFixtureRequestDto {
  final int fixtureId;
  final int teamId;
  final VideoReactionFilter filter;
  final int start;

  GetVideoReactionsForFixtureRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.filter,
    @required this.start,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['filter'] = filter.index;
    map['start'] = start;

    return map;
  }
}
