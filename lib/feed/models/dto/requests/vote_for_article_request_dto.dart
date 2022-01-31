import 'package:flutter/foundation.dart';

class VoteForArticleRequestDto {
  final int articleId;
  final int userVote;

  VoteForArticleRequestDto({
    @required this.articleId,
    @required this.userVote,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['articleId'] = articleId;
    map['userVote'] = userVote;

    return map;
  }
}
