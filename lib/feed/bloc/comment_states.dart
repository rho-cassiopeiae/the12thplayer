import 'package:flutter/foundation.dart';

import '../models/vm/comment_vm.dart';

abstract class CommentState {}

abstract class LoadCommentsState extends CommentState {}

class CommentsLoading extends LoadCommentsState {}

class CommentsReady extends LoadCommentsState {
  final List<CommentVm> comments;

  CommentsReady({@required this.comments});
}

abstract class PostCommentState extends CommentState {}

class CommentPostingSucceeded extends PostCommentState {
  final CommentVm comment;

  CommentPostingSucceeded({@required this.comment});
}

class CommentPostingFailed extends PostCommentState {}
