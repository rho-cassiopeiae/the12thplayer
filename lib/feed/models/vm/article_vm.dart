import 'dart:convert';

import '../../enums/article_type.dart';
import '../dto/article_dto.dart';

class ArticleVm {
  final DateTime postedAt;
  final int authorId;
  final String authorUsername;
  final ArticleType type;
  final String title;
  final String previewImageUrl;
  final String summary;
  final List<dynamic> content;

  ArticleVm.fromDto(ArticleDto article)
      : postedAt = DateTime.fromMillisecondsSinceEpoch(article.postedAt),
        authorId = article.authorId,
        authorUsername = article.authorUsername,
        type = ArticleType.values[article.type],
        title = article.title,
        previewImageUrl = article.previewImageUrl,
        summary = article.summary,
        content = jsonDecode(article.content);
}
