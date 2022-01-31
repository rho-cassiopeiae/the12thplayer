import 'package:flutter/foundation.dart';
import 'package:ulid/ulid.dart';

import '../dto/comment_dto.dart';

class CommentVm {
  final String id;
  final String rootId;
  final String parentId;
  final int authorId;
  final String authorUsername;
  final DateTime postedAt;
  final int rating;
  final String body;
  final int userVote;
  final List<CommentVm> children = [];

  CommentVm({
    @required this.id,
    @required this.rootId,
    @required this.parentId,
    @required this.authorId,
    @required this.authorUsername,
    @required this.postedAt,
    @required this.rating,
    @required this.body,
    @required this.userVote,
  });

  CommentVm.fromDto(CommentDto comment)
      : id = comment.id,
        rootId = comment.rootId,
        parentId = comment.parentId,
        authorId = comment.authorId,
        authorUsername = comment.authorUsername,
        postedAt = DateTime.fromMillisecondsSinceEpoch(
          Ulid.parse(comment.id).toMillis(),
        ),
        rating = comment.rating,
        body = comment.body,
        userVote = comment.userVote;

  CommentVm deepCopy() {
    var commentCopy = CommentVm(
      id: id,
      rootId: rootId,
      parentId: parentId,
      authorId: authorId,
      authorUsername: authorUsername,
      postedAt: postedAt,
      rating: rating,
      body: body,
      userVote: userVote,
    );
    commentCopy.children.addAll(
      children.map((childComment) => childComment.deepCopy()).toList(),
    );

    return commentCopy;
  }

  CommentVm copyWith({
    @required int rating,
    @required int userVote,
  }) {
    var commentCopy = CommentVm(
      id: id,
      rootId: rootId,
      parentId: parentId,
      authorId: authorId,
      authorUsername: authorUsername,
      postedAt: postedAt,
      rating: rating,
      body: body,
      userVote: userVote,
    );
    commentCopy.children.addAll(children);

    return commentCopy;
  }
}
