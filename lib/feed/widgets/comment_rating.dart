import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/comment_actions.dart';
import '../bloc/comment_bloc.dart';
import '../models/vm/comment_vm.dart';
import '../../general/extensions/kiwi_extension.dart';

class CommentRating extends StatefulWidget {
  final String commentBlocInstanceIdentifier;
  final String commentPath;
  final int articleId;
  final CommentVm comment;

  const CommentRating({
    Key key,
    @required this.commentBlocInstanceIdentifier,
    @required this.commentPath,
    @required this.articleId,
    @required this.comment,
  }) : super(key: key);

  @override
  _CommentRatingState createState() => _CommentRatingState();
}

class _CommentRatingState extends StateWith<CommentRating, CommentBloc> {
  CommentBloc get _commentBloc => service;

  @override
  String get dependencyInstanceIdentifier =>
      widget.commentBlocInstanceIdentifier;

  int _rating;
  int _userVote;

  @override
  void initState() {
    super.initState();
    _rating = widget.comment.rating;
    _userVote = widget.comment.userVote;
  }

  @override
  void didUpdateWidget(covariant CommentRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rating = widget.comment.rating;
    _userVote = widget.comment.userVote;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              int incrRatingBy;
              if (_userVote == null) {
                _userVote = -1;
                incrRatingBy = -1;
              } else if (_userVote == -1) {
                _userVote = null;
                incrRatingBy = 1;
              } else {
                _userVote = -1;
                incrRatingBy = -2;
              }

              _rating += incrRatingBy;
            });

            _commentBloc.dispatchAction(VoteForComment(
              articleId: widget.articleId,
              commentId: widget.comment.id,
              commentPath: widget.commentPath,
              userVote: _userVote,
            ));
          },
          padding: EdgeInsets.zero,
          iconSize: 30.0,
          color: _userVote == -1 ? Colors.orange : null,
          icon: Icon(Icons.arrow_drop_down),
        ),
        Container(
          width: 20.0,
          alignment: Alignment.center,
          child: AutoSizeText(
            _rating.toString(),
            style: GoogleFonts.lexendMega(
              fontSize: 18.0,
            ),
            maxLines: 1,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              int incrRatingBy;
              if (_userVote == null) {
                _userVote = 1;
                incrRatingBy = 1;
              } else if (_userVote == 1) {
                _userVote = null;
                incrRatingBy = -1;
              } else {
                _userVote = 1;
                incrRatingBy = 2;
              }

              _rating += incrRatingBy;
            });

            _commentBloc.dispatchAction(VoteForComment(
              articleId: widget.articleId,
              commentId: widget.comment.id,
              commentPath: widget.commentPath,
              userVote: _userVote,
            ));
          },
          padding: EdgeInsets.zero,
          iconSize: 30.0,
          color: _userVote == 1 ? Colors.orange : null,
          icon: Icon(Icons.arrow_drop_up),
        ),
      ],
    );
  }
}
