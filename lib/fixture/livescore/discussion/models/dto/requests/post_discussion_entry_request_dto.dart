import 'package:flutter/foundation.dart';

class PostDiscussionEntryRequestDto {
  final int fixtureId;
  final int teamId;
  final String discussionIdentifier;
  final String body;

  PostDiscussionEntryRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.discussionIdentifier,
    @required this.body,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['discussionIdentifier'] = discussionIdentifier;
    map['body'] = body;

    return map;
  }
}
