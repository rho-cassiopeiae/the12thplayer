import 'package:flutter/foundation.dart';

import 'comment_vm.dart';

class ArticleCommentsVm {
  final int articleId;
  final List<CommentVm> comments;

  ArticleCommentsVm({
    @required this.articleId,
    @required this.comments,
  });
}
