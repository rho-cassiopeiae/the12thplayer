import 'package:flutter/foundation.dart';

class SubscribeToDiscussionRequestDto {
  final int fixtureId;
  final int teamId;
  final String discussionIdentifier;

  SubscribeToDiscussionRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.discussionIdentifier,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['discussionIdentifier'] = discussionIdentifier;

    return map;
  }
}
