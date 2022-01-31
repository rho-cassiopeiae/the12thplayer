import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/comment_states.dart';
import '../bloc/comment_actions.dart';
import '../bloc/comment_bloc.dart';
import '../../general/extensions/kiwi_extension.dart';

class PostCommentButton extends StatefulWidget
    with DependencyResolver<CommentBloc> {
  final String commentBlocInstanceIdentifier;
  final int articleId;
  final String commentPath;
  final double size;
  final double iconSize;

  PostCommentButton({
    Key key,
    @required this.commentBlocInstanceIdentifier,
    @required this.articleId,
    @required this.commentPath,
    @required this.size,
    @required this.iconSize,
  });

  @override
  _PostCommentButtonState createState() =>
      _PostCommentButtonState(resolve(commentBlocInstanceIdentifier));
}

class _PostCommentButtonState extends State<PostCommentButton> {
  final CommentBloc _commentBloc;

  String _body;

  _PostCommentButtonState(this._commentBloc);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      child: IconButton(
        onPressed: () async {
          await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
                title: Text(
                  widget.commentPath == null ? 'Comment' : 'Reply',
                  style: GoogleFonts.patuaOne(
                    fontSize: 20.0,
                  ),
                ),
                content: TextField(
                  onChanged: (value) => _body = value,
                  style: GoogleFonts.signikaNegative(
                    fontSize: 20.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your ' +
                        (widget.commentPath == null ? 'comment' : 'reply'),
                    hintStyle: GoogleFonts.signikaNegative(
                      fontSize: 20.0,
                    ),
                  ),
                  minLines: 5,
                  maxLines: 5,
                ),
                actions: [
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        const Color(0xff4059ad),
                      ),
                      fixedSize: MaterialStateProperty.all(
                        Size(50.0, 30.0),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    child: Text(
                      'Post',
                      style: GoogleFonts.signikaNegative(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                    onPressed: () async {
                      var action = PostComment(
                        articleId: widget.articleId,
                        commentPath: widget.commentPath,
                        body: _body,
                      );
                      _commentBloc.dispatchAction(action);

                      var state = await action.state;
                      if (state is CommentPostingSucceeded) {
                        Navigator.of(context).pop(true);
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        padding: EdgeInsets.zero,
        color: const Color(0xff4059ad),
        iconSize: widget.iconSize,
        icon: Icon(Icons.add_comment),
      ),
    );
  }
}
