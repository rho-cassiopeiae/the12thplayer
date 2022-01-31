import 'package:flutter/foundation.dart';

class SubscribeToDiscussionRequestDto {
  final int fixtureId;
  final int teamId;
  final String discussionId;

  SubscribeToDiscussionRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.discussionId,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['discussionId'] = discussionId;

    return map;
  }
}
