import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/feed_actions.dart';
import '../bloc/feed_bloc.dart';
import '../models/vm/article_vm.dart';
import '../../general/extensions/kiwi_extension.dart';

class ArticleRating extends StatefulWidget {
  final ArticleVm article;

  const ArticleRating({
    Key key,
    @required this.article,
  }) : super(key: key);

  @override
  _ArticleRatingState createState() => _ArticleRatingState();
}

class _ArticleRatingState extends StateWith<ArticleRating, FeedBloc> {
  FeedBloc get _feedBloc => service;

  int _rating;
  int _userVote;

  @override
  void initState() {
    super.initState();
    _rating = widget.article.rating;
    _userVote = widget.article.userVote;
  }

  @override
  void didUpdateWidget(covariant ArticleRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rating = widget.article.rating;
    _userVote = widget.article.userVote;
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

            _feedBloc.dispatchAction(VoteForArticle(
              articleId: widget.article.id,
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

            _feedBloc.dispatchAction(VoteForArticle(
              articleId: widget.article.id,
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
