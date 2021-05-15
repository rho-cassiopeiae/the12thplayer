import 'package:flutter/foundation.dart';

class UnsubscribeFromLiveCommentaryFeedRequestDto {
  final int fixtureId;
  final int teamId;
  final int authorId;

  UnsubscribeFromLiveCommentaryFeedRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.authorId,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['authorId'] = authorId;

    return map;
  }
}
