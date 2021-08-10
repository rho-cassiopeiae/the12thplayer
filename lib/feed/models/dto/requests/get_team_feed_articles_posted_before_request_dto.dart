import 'package:flutter/foundation.dart';

class GetTeamFeedArticlesPostedBeforeRequestDto {
  final int teamId;
  final DateTime postedBefore;

  GetTeamFeedArticlesPostedBeforeRequestDto({
    @required this.teamId,
    @required this.postedBefore,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['teamId'] = teamId;
    map['postedBefore'] = postedBefore?.millisecondsSinceEpoch;

    return map;
  }
}
