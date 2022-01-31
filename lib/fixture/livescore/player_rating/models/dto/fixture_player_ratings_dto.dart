import 'player_rating_dto.dart';

class FixturePlayerRatingsDto {
  final bool ratingsFinalized;
  final Iterable<PlayerRatingDto> playerRatings;

  FixturePlayerRatingsDto.fromMap(Map<String, dynamic> map)
      : ratingsFinalized = map['ratingsFinalized'],
        playerRatings = (map['playerRatings'] as List)
            .map((ratingMap) => PlayerRatingDto.fromMap(ratingMap));
}
