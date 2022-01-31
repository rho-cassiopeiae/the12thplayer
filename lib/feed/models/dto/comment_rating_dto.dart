class CommentRatingDto {
  final int rating;

  CommentRatingDto.fromMap(Map<String, dynamic> map) : rating = map['rating'];
}
