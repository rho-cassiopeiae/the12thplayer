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
  final String content;

  bool get isVideo =>
      type == ArticleType.Video || type == ArticleType.Highlights;

  bool get isYoutubeVideo =>
      content.contains('youtube.com') || content.contains('youtu.be');

  List<dynamic> get contentList => jsonDecode(content);

  ArticleVm.fromDto(ArticleDto article)
      : postedAt = DateTime.fromMillisecondsSinceEpoch(article.postedAt),
        authorId = article.authorId,
        authorUsername = article.authorUsername,
        type = ArticleType.values[article.type],
        title = article.title,
        previewImageUrl = article.previewImageUrl,
        summary = article.summary,
        content = article.content;
}
