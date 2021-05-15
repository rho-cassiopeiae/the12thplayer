import 'package:flutter/foundation.dart';

import '../../../enums/live_commentary_feed_vote_action.dart';

class VoteForLiveCommentaryFeedRequestDto {
  final int fixtureId;
  final int teamId;
  final int authorId;
  final LiveCommentaryFeedVoteAction voteAction;

  VoteForLiveCommentaryFeedRequestDto({
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
    map['voteAction'] = voteAction.index;

    return map;
  }
}
