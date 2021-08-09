import 'package:flutter/foundation.dart';

import '../../../enums/article_type.dart';

class PostArticleRequestDto {
  final int teamId;
  final ArticleType type;
  final String title;
  final String previewImageUrl;
  final String summary;
  final String content;

  PostArticleRequestDto({
    @required this.teamId,
    @required this.type,
    @required this.title,
    @required this.previewImageUrl,
    @required this.summary,
    @required this.content,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['teamId'] = teamId;
    map['type'] = type.index;
    map['title'] = title;
    map['previewImageUrl'] = previewImageUrl;
    map['summary'] = summary;
    map['content'] = content;

    return map;
  }
}
