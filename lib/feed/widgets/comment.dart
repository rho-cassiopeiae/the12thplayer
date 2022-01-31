import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

import 'comment_rating.dart';
import '../widgets/post_comment_button.dart';
import '../models/vm/comment_vm.dart';
import '../pages/comment_replies_page.dart';

class Comment extends StatelessWidget {
  final String _profileImageUrl = FlutterConfig.get('PROFILE_API_BASE_URL') +
      FlutterConfig.get('PROFILE_IMAGE_PATH');

  final String commentBlocInstanceIdentifier;
  final int articleId;
  final String commentPath;
  final CommentVm comment;
  final bool topView;

  Comment({
    Key key,
    @required this.commentBlocInstanceIdentifier,
    @required this.articleId,
    @required this.commentPath,
    @required this.comment,
    @required this.topView,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: comment.id,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16.0, 12.0, 11.0, 12.0),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color:
                    topView ? const Color(0xcc580aff) : const Color(0xffce6a85),
                width: 5.0,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      _profileImageUrl + '/${comment.authorUsername}.png',
                      errorBuilder: (context, _, __) => Image.asset(
                        'assets/images/dummy_profile_image.png',
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Card(
                    color: const Color(0xff6b9ac4),
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        comment.authorUsername,
                        style: GoogleFonts.patuaOne(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    DateFormat('h:mm a').format(comment.postedAt),
                    style: GoogleFonts.patuaOne(
                      fontSize: 18.0,
                      color: Colors.black26,
                    ),
                  ),
                  SizedBox(width: 12.0),
                ],
              ),
              SizedBox(height: 12.0),
              Text(
                comment.body,
                style: GoogleFonts.signikaNegative(
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: topView
                                ? () => Navigator.of(context).pop()
                                : () {
                                    if (comment.children.length > 0) {
                                      Navigator.of(context).pushNamed(
                                        CommentRepliesPage.routeName,
                                        arguments: Tuple4(
                                          commentBlocInstanceIdentifier,
                                          articleId,
                                          commentPath,
                                          comment,
                                        ),
                                      );
                                    }
                                  },
                            child: Container(
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: topView
                                    ? const Color(0xff4059ad)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: topView
                                    ? null
                                    : Border.all(
                                        color: const Color(0xff4059ad),
                                        width: 2.0,
                                      ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Replies (${comment.children.length})',
                                style: GoogleFonts.signikaNegative(
                                  color: topView
                                      ? Colors.white
                                      : const Color(0xff4059ad),
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        PostCommentButton(
                          commentBlocInstanceIdentifier:
                              commentBlocInstanceIdentifier,
                          articleId: articleId,
                          commentPath: commentPath,
                          size: 40.0,
                          iconSize: 25.0,
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  CommentRating(
                    commentBlocInstanceIdentifier:
                        commentBlocInstanceIdentifier,
                    commentPath: commentPath,
                    articleId: articleId,
                    comment: comment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
