import 'package:flutter/foundation.dart';

import '../../general/bloc/mixins.dart';
import 'comment_states.dart';

abstract class CommentAction {}

abstract class CommentActionAwaitable<T extends CommentState>
    extends CommentAction with AwaitableState<T> {}

class LoadComments extends CommentAction {
  final int articleId;

  LoadComments({@required this.articleId});
}

class VoteForComment extends CommentAction {
  final int articleId;
  final String commentId;
  final String commentPath;
  final int userVote;

  VoteForComment({
    @required this.articleId,
    @required this.commentId,
    @required this.commentPath,
    @required this.userVote,
  });
}

class PostComment extends CommentActionAwaitable<PostCommentState> {
  final int articleId;
  final String commentPath;
  final String body;

  PostComment({
    @required this.articleId,
    @required this.commentPath,
    @required this.body,
  });
}
