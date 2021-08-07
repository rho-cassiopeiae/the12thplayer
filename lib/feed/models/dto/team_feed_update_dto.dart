import 'article_dto.dart';

class TeamFeedUpdateDto {
  final int teamId;
  final Iterable<ArticleDto> articles;

  TeamFeedUpdateDto.fromMap(Map<String, dynamic> map)
      : teamId = map['teamId'],
        articles = (map['articles'] as List<dynamic>)
            .map((articleMap) => ArticleDto.fromMap(articleMap));
}
