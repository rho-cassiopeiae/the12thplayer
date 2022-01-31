import 'package:flutter/foundation.dart';

class GetCommentsForArticleRequestDto {
  final int articleId;

  GetCommentsForArticleRequestDto({@required this.articleId});

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['articleId'] = articleId;

    return map;
  }
}
