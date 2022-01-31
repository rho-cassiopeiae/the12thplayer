import 'package:flutter/foundation.dart';

class GetMoreDiscussionEntriesRequestDto {
  final int fixtureId;
  final int teamId;
  final String discussionId;
  final String lastReceivedEntryId;

  GetMoreDiscussionEntriesRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.discussionId,
    @required this.lastReceivedEntryId,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['discussionId'] = discussionId;
    map['lastReceivedEntryId'] = lastReceivedEntryId;

    return map;
  }
}
