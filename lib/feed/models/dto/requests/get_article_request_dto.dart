import 'package:flutter/foundation.dart';

class GetArticleRequestDto {
  final int articleId;

  GetArticleRequestDto({@required this.articleId});

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['articleId'] = articleId;

    return map;
  }
}
