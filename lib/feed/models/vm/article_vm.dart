import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../enums/article_type.dart';
import '../dto/article_dto.dart';

class ArticleVm {
  final int id;
  final int authorId;
  final String authorUsername;
  final DateTime postedAt;
  final ArticleType type;
  final String title;
  final String previewImageUrl;
  final String summary;
  final String content;
  final int rating;
  final int commentCount;
  final int userVote;

  ArticleVm._(
    this.id,
    this.authorId,
    this.authorUsername,
    this.postedAt,
    this.type,
    this.title,
    this.previewImageUrl,
    this.summary,
    this.content,
    this.rating,
    this.commentCount,
    this.userVote,
  );

  bool get isVideo =>
      type == ArticleType.Video || type == ArticleType.Highlights;

  bool get isYoutubeVideo =>
      content.contains('youtube.com') || content.contains('youtu.be');

  List<dynamic> get contentList => jsonDecode(content);

  ArticleVm.fromDto(ArticleDto article)
      : id = article.id,
        authorId = article.authorId,
        authorUsername = article.authorUsername,
        postedAt = DateTime.fromMillisecondsSinceEpoch(article.postedAt),
        type = ArticleType.values[article.type],
        title = article.title,
        previewImageUrl = article.previewImageUrl,
        summary = article.summary,
        content = article.content,
        rating = article.rating,
        commentCount = article.commentCount,
        userVote = article.userVote;

  ArticleVm copyWith({
    @required int rating,
    @required int userVote,
  }) {
    return ArticleVm._(
      id,
      authorId,
      authorUsername,
      postedAt,
      type,
      title,
      previewImageUrl,
      summary,
      content,
      rating,
      commentCount,
      userVote,
    );
  }
}
