import 'package:flutter/foundation.dart';

class PostCommentRequestDto {
  final int articleId;
  final String threadRootCommentId;
  final String parentCommentId;
  final String body;

  PostCommentRequestDto({
    @required this.articleId,
    @required this.threadRootCommentId,
    @required this.parentCommentId,
    @required this.body,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['articleId'] = articleId;
    map['threadRootCommentId'] = threadRootCommentId;
    map['parentCommentId'] = parentCommentId;
    map['body'] = body;

    return map;
  }
}
