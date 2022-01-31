class VideoReactionRatingDto {
  final int rating;

  VideoReactionRatingDto.fromMap(Map<String, dynamic> map)
      : rating = map['rating'];
}
