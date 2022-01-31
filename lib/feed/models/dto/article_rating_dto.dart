class ArticleRatingDto {
  final int rating;

  ArticleRatingDto.fromMap(Map<String, dynamic> map) : rating = map['rating'];
}
