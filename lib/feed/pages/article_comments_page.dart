import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ulid/ulid.dart';

import '../bloc/feed_bloc.dart';
import '../bloc/feed_states.dart';
import '../widgets/article_preview.dart';
import '../widgets/comment.dart';
import '../bloc/comment_states.dart';
import '../enums/comment_filter.dart';
import '../models/vm/article_vm.dart';
import '../../general/extensions/kiwi_extension.dart';
import '../bloc/comment_actions.dart';
import '../bloc/comment_bloc.dart';

class ArticleCommentsPage extends StatefulWidget
    with DependencyResolver2<FeedBloc, CommentBloc> {
  static const routeName = '/feed/article/comments';

  final String commentBlocInstanceIdentifier =
      '<CommentBloc>:${Ulid().toString()}';

  final ArticleVm article;

  ArticleCommentsPage({
    Key key,
    @required this.article,
  }) : super(key: key);

  @override
  _ArticleCommentsPageState createState() => _ArticleCommentsPageState(
        resolve1(),
        resolve2(commentBlocInstanceIdentifier),
      );
}

class _ArticleCommentsPageState extends State<ArticleCommentsPage> {
  final FeedBloc _feedBloc;
  final CommentBloc _commentBloc;

  CommentFilter _filter;

  _ArticleCommentsPageState(
    this._feedBloc,
    this._commentBloc,
  );

  @override
  void initState() {
    super.initState();

    _filter = CommentFilter.OldestFirst;

    _commentBloc.dispatchAction(
      LoadComments(articleId: widget.article.id),
    );
  }

  @override
  void dispose() {
    _commentBloc.dispose();
    widget.disposeOfDependencyInstance(widget.commentBlocInstanceIdentifier);

    super.dispose();
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
        brightness: Brightness.dark,
        centerTitle: true,
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              _commentBloc.dispatchAction(
                LoadComments(articleId: widget.article.id),
              );
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<LoadArticlesState>(
            initialData: ArticlesLoading(),
            stream: _feedBloc.feedArticlesState$,
            builder: (context, snapshot) {
              ArticleVm article;
              var state = snapshot.data;
              if (state is ArticlesLoading) {
                article = widget.article;
              } else {
                var articles = (state as ArticlesReady).feedArticles.articles;
                article = articles.singleWhere(
                  (a) => a.id == widget.article.id,
                  orElse: () => widget.article,
                );
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ArticlePreview(
                    article: article,
                    commentBlocInstanceIdentifier:
                        widget.commentBlocInstanceIdentifier,
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

              var comments = (state as CommentsReady).comments.toList();
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
                      articleId: widget.article.id,
                      commentPath: comment.id,
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
