import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/comment.dart';
import '../bloc/comment_actions.dart';
import '../bloc/comment_states.dart';
import '../enums/comment_filter.dart';
import '../models/vm/comment_vm.dart';
import '../bloc/comment_bloc.dart';
import '../../general/extensions/kiwi_extension.dart';

class CommentRepliesPage extends StatefulWidget {
  static const routeName = '/feed/article/comments/replies';

  final String commentBlocInstanceIdentifier;
  final int articleId;
  final String commentPath;
  final CommentVm comment;

  const CommentRepliesPage({
    Key key,
    @required this.commentBlocInstanceIdentifier,
    @required this.articleId,
    @required this.commentPath,
    @required this.comment,
  }) : super(key: key);

  @override
  _CommentRepliesPageState createState() => _CommentRepliesPageState();
}

class _CommentRepliesPageState
    extends StateWith<CommentRepliesPage, CommentBloc> {
  CommentBloc get _commentBloc => service;

  @override
  String get dependencyInstanceIdentifier =>
      widget.commentBlocInstanceIdentifier;

  CommentFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = CommentFilter.OldestFirst;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 241, 246, 1.0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF273469),
        title: Text(
          'The 12th Player',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              _commentBloc.dispatchAction(
                LoadComments(articleId: widget.articleId),
              );
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<LoadCommentsState>(
            initialData: CommentsLoading(),
            stream: _commentBloc.articleCommentsState$,
            builder: (context, snapshot) {
              CommentVm comment;
              var state = snapshot.data;
              if (state is CommentsLoading) {
                comment = widget.comment;
              } else {
                var comments = (state as CommentsReady).comments;

                var ancestorCommentIds = widget.commentPath.split('<-')
                  ..removeLast();
                for (var ancestorCommentId in ancestorCommentIds) {
                  comments = comments
                      ?.singleWhere(
                        (comment) => comment.id == ancestorCommentId,
                        orElse: () => null,
                      )
                      ?.children;
                }

                comment = comments?.singleWhere(
                      (c) => c.id == widget.comment.id,
                      orElse: () => null,
                    ) ??
                    widget.comment;
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Comment(
                    commentBlocInstanceIdentifier:
                        widget.commentBlocInstanceIdentifier,
                    articleId: widget.articleId,
                    commentPath: widget.commentPath,
                    comment: comment,
                    topView: true,
                  ),
                ),
              );
            },
          ),
          StreamBuilder<LoadCommentsState>(
            initialData: CommentsLoading(),
            stream: _commentBloc.articleCommentsState$,
            builder: (context, snapshot) {
              var state = snapshot.data;
              if (state is CommentsLoading) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              var comments = (state as CommentsReady).comments;

              var ancestorCommentIds = widget.commentPath.split('<-');
              for (var ancestorCommentId in ancestorCommentIds) {
                comments = comments
                    .singleWhere((comment) => comment.id == ancestorCommentId)
                    .children;
              }
              comments = comments.toList();

              switch (_filter) {
                case CommentFilter.Top:
                  comments.sort((c1, c2) => c2.rating.compareTo(c1.rating));
                  break;
                case CommentFilter.NewestFirst:
                  comments.sort((c1, c2) => c2.postedAt.compareTo(c1.postedAt));
                  break;
                case CommentFilter.OldestFirst:
                  comments.sort((c1, c2) => c1.postedAt.compareTo(c2.postedAt));
                  break;
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var comment = comments[index];
                    return Comment(
                      commentBlocInstanceIdentifier:
                          widget.commentBlocInstanceIdentifier,
                      articleId: widget.articleId,
                      commentPath: '${widget.commentPath}<-${comment.id}',
                      comment: comment,
                      topView: false,
                    );
                  },
                  childCount: comments.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
