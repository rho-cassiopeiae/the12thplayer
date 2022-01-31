import 'package:flutter/foundation.dart';

class VoteForVideoReactionRequestDto {
  final int fixtureId;
  final int teamId;
  final int authorId;
  final int userVote;

  VoteForVideoReactionRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.authorId,
    @required this.userVote,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['authorId'] = authorId;
    map['userVote'] = userVote;

    return map;
  }
}
