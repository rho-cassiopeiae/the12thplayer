import 'package:flutter/foundation.dart';

import '../../../enums/video_reaction_vote_action.dart';

class VoteForVideoReactionRequestDto {
  final int fixtureId;
  final int teamId;
  final int authorId;
  final VideoReactionVoteAction voteAction;

  VoteForVideoReactionRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.authorId,
    @required this.voteAction,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['authorId'] = authorId;
    map['voteAction'] = voteAction.toInt();

    return map;
  }
}
