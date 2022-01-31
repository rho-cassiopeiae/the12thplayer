import 'package:flutter/foundation.dart';

class VoteForCommentRequestDto {
  final int articleId;
  final String commentId;
  final int userVote;

  VoteForCommentRequestDto({
    @required this.articleId,
    @required this.commentId,
    @required this.userVote,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['articleId'] = articleId;
    map['commentId'] = commentId;
    map['userVote'] = userVote;

    return map;
  }
}
