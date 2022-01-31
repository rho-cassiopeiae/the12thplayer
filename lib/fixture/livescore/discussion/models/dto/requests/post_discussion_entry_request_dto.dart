import 'package:flutter/foundation.dart';

class PostDiscussionEntryRequestDto {
  final int fixtureId;
  final int teamId;
  final String discussionId;
  final String body;

  PostDiscussionEntryRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.discussionId,
    @required this.body,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['discussionId'] = discussionId;
    map['body'] = body;

    return map;
  }
}
