import 'package:flutter/foundation.dart';

import '../../../enums/live_commentary_filter.dart';

class GetLiveCommentaryFeedsForFixtureRequestDto {
  final int fixtureId;
  final int teamId;
  final LiveCommentaryFilter filter;
  final int start;

  GetLiveCommentaryFeedsForFixtureRequestDto({
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
