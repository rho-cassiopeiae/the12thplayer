import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../enums/live_commentary_feed_vote_action.dart';
import '../../persistence/tables/fixture_live_commentary_feed_votes_table.dart';

class FixtureLiveCommentaryFeedVotesEntity {
  final int fixtureId;
  final int teamId;
  Map<int, LiveCommentaryFeedVoteAction> _authorIdToVoteAction;
  Map<int, LiveCommentaryFeedVoteAction> get authorIdToVoteAction =>
      _authorIdToVoteAction;

  FixtureLiveCommentaryFeedVotesEntity.noVotes({
    @required this.fixtureId,
    @required this.teamId,
  }) {
    _authorIdToVoteAction = {};
  }

  FixtureLiveCommentaryFeedVotesEntity.fromMap(Map<String, dynamic> map)
      : fixtureId = map[FixtureLiveCommentaryFeedVotesTable.fixtureId],
        teamId = map[FixtureLiveCommentaryFeedVotesTable.teamId] {
    _authorIdToVoteAction = (jsonDecode(
                map[FixtureLiveCommentaryFeedVotesTable.authorIdToVoteAction])
            as Map<String, dynamic>)
        .map(
      (key, value) => MapEntry(
        int.parse(key),
        LiveCommentaryFeedVoteAction.values[value],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[FixtureLiveCommentaryFeedVotesTable.fixtureId] = fixtureId;
    map[FixtureLiveCommentaryFeedVotesTable.teamId] = teamId;
    map[FixtureLiveCommentaryFeedVotesTable.authorIdToVoteAction] = jsonEncode(
      authorIdToVoteAction.map(
        (authorId, voteAction) =>
            MapEntry(authorId.toString(), voteAction.index),
      ),
    );

    return map;
  }
}
