import 'dart:convert';

import '../dto/fixture_player_ratings_dto.dart';
import '../../persistence/tables/fixture_player_ratings_table.dart';
import 'player_rating_entity.dart';

class FixturePlayerRatingsEntity {
  final int fixtureId;
  final int teamId;
  final bool finalized;
  final List<PlayerRatingEntity> playerRatings;

  FixturePlayerRatingsEntity.fromMap(Map<String, dynamic> map)
      : fixtureId = map[FixturePlayerRatingsTable.fixtureId],
        teamId = map[FixturePlayerRatingsTable.teamId],
        finalized = map[FixturePlayerRatingsTable.finalized] == 1,
        playerRatings =
            (jsonDecode(map[FixturePlayerRatingsTable.playerRatings]) as List)
                .map((ratingMap) => PlayerRatingEntity.fromMap(ratingMap))
                .toList();

  FixturePlayerRatingsEntity.empty(int fixtureId, int teamId)
      : fixtureId = fixtureId,
        teamId = teamId,
        finalized = false,
        playerRatings = [];

  FixturePlayerRatingsEntity.fromDto(
    int fixtureId,
    int teamId,
    FixturePlayerRatingsDto fixturePlayerRatings,
  )   : fixtureId = fixtureId,
        teamId = teamId,
        finalized = fixturePlayerRatings.ratingsFinalized,
        playerRatings = fixturePlayerRatings.playerRatings
            .map((pr) => PlayerRatingEntity.fromDto(pr))
            .toList();

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[FixturePlayerRatingsTable.fixtureId] = fixtureId;
    map[FixturePlayerRatingsTable.teamId] = teamId;
    map[FixturePlayerRatingsTable.finalized] = finalized ? 1 : 0;
    map[FixturePlayerRatingsTable.playerRatings] = jsonEncode(playerRatings);

    return map;
  }
}
