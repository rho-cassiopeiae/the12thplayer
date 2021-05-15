import 'package:flutter/foundation.dart';

class SubscribeToLiveCommentaryFeedRequestDto {
  final int fixtureId;
  final int teamId;
  final int authorId;
  final String lastReceivedEntryId;

  SubscribeToLiveCommentaryFeedRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.authorId,
    @required this.lastReceivedEntryId,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['authorId'] = authorId;
    map['lastReceivedEntryId'] = lastReceivedEntryId;

    return map;
  }
}
