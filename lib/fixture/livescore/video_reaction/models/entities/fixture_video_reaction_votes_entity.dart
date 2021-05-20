import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../enums/video_reaction_vote_action.dart';
import '../../persistence/tables/fixture_video_reaction_votes_table.dart';

class FixtureVideoReactionVotesEntity {
  final int fixtureId;
  final int teamId;
  Map<int, VideoReactionVoteAction> _authorIdToVoteAction;
  Map<int, VideoReactionVoteAction> get authorIdToVoteAction =>
      _authorIdToVoteAction;

  FixtureVideoReactionVotesEntity.noVotes({
    @required this.fixtureId,
    @required this.teamId,
  }) {
    _authorIdToVoteAction = {};
  }

  FixtureVideoReactionVotesEntity.fromMap(Map<String, dynamic> map)
      : fixtureId = map[FixtureVideoReactionVotesTable.fixtureId],
        teamId = map[FixtureVideoReactionVotesTable.teamId] {
    _authorIdToVoteAction =
        (jsonDecode(map[FixtureVideoReactionVotesTable.authorIdToVoteAction])
                as Map<String, dynamic>)
            .map(
      (key, value) => MapEntry(
        int.parse(key),
        VideoReactionVoteAction.values[value],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[FixtureVideoReactionVotesTable.fixtureId] = fixtureId;
    map[FixtureVideoReactionVotesTable.teamId] = teamId;
    map[FixtureVideoReactionVotesTable.authorIdToVoteAction] = jsonEncode(
      authorIdToVoteAction.map(
        (authorId, voteAction) =>
            MapEntry(authorId.toString(), voteAction.index),
      ),
    );

    return map;
  }
}
