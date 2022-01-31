import '../../../../../general/extensions/map_extension.dart';

class PlayerRatingDto {
  final String participantKey;
  final int totalRating;
  final int totalVoters;
  final double userRating;

  PlayerRatingDto.fromMap(Map<String, dynamic> map)
      : participantKey = map['participantKey'],
        totalRating = map['totalRating'],
        totalVoters = map['totalVoters'],
        userRating = map.getOrNull('userRating')?.toDouble();
}
