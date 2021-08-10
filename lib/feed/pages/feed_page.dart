import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'article_page.dart';
import '../../general/widgets/app_drawer.dart';
import 'article_type_selection_page.dart';
import 'youtube_video_page.dart';
import '../bloc/feed_actions.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_states.dart';
import '../enums/article_type.dart';
import '../../general/extensions/kiwi_extension.dart';

class FeedPage extends StatefulWidget with DependencyResolver<FeedBloc> {
  static const routeName = '/feed';

  const FeedPage({Key key}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState(resolve());
}

class _FeedPageState extends State<FeedPage> {
  final FeedBloc _feedBloc;

  RefreshController _refreshController;

  _FeedPageState(this._feedBloc);

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _feedBloc.dispatchAction(SubscribeToFeed());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _feedBloc.dispatchAction(UnsubscribeFromFeed());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 241, 246, 1.0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF273469),
        title: Text(
          'The12thPlayer',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
        brightness: Brightness.dark,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(
                ArticleTypeSelectionPage.routeName,
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<ArticlesState>(
        initialData: ArticlesLoading(),
        stream: _feedBloc.articlesState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is ArticlesLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ArticlesError) {
            return Center(
              child: Text(state.message),
            );
          }

          var articles = (state as ArticlesReady).articles;

          return SmartRefresher(
            footer: CustomFooter(
              loadStyle: LoadStyle.ShowWhenLoading,
              builder: (_, mode) {
                Widget widget;
                switch (mode) {
                  case LoadStatus.idle:
                    widget = Text('Pull up to load more');
                    break;
                  case LoadStatus.loading:
                    widget = CircularProgressIndicator();
                    break;
                  case LoadStatus.canLoading:
                    widget = Text('Release to load more');
                    break;
                  default:
                    widget = SizedBox.shrink();
                    break;
                }

                return Container(
                  height: 50,
                  child: Center(child: widget),
                );
              },
            ),
            controller: _refreshController,
            onLoading: () async {
              var action = LoadMoreArticles();
              _feedBloc.dispatchAction(action);

              await action.state;

              _refreshController.loadComplete();
            },
            enablePullDown: false,
            enablePullUp: true,
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                var article = articles[index];
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      color: index % 2 == 0
                          ? const Color(0xccbc4749)
                          : const Color(0xFF219ebc),
                      margin: const EdgeInsets.only(top: 12),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
                        child: Text(
                          DateFormat('h:mm a   MMM d').format(article.postedAt),
                          style: GoogleFonts.patuaOne(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Card(
                      color: const Color.fromRGBO(238, 241, 246, 1.0),
                      elevation: 8,
                      margin: const EdgeInsets.fromLTRB(16, 52, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article.isVideo)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                color: Colors.black87,
                                child: Stack(
                                  alignment: Alignment.center,
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      article.previewImageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (article.isYoutubeVideo) {
                                          Navigator.of(context).pushNamed(
                                            YoutubeVideoPage.routeName,
                                            arguments: article.content,
                                          );
                                        } else {
                                          throw UnimplementedError();
                                        }
                                      },
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white54,
                                        size: 80,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (!article.isVideo &&
                              article.previewImageUrl != null)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                color: Colors.black87,
                                child: Image.network(
                                  article.previewImageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          if (article.previewImageUrl == null)
                            SizedBox(height: 14),
                          GestureDetector(
                            onTap: !article.isVideo
                                ? () {
                                    Navigator.of(context).pushNamed(
                                      ArticlePage.routeName,
                                      arguments: article.postedAt,
                                    );
                                  }
                                : null,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                              child: Text(
                                article.title,
                                style: GoogleFonts.patuaOne(
                                  fontSize: 24,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (article.summary != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                              child: Text(
                                article.summary,
                                style: GoogleFonts.josefinSans(
                                  fontSize: 22,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 30,
                      left: 16,
                      child: Card(
                        color: const Color(0xff2b2d42),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          child: Text(
                            article.type.getString(),
                            style: GoogleFonts.patuaOne(
                              fontSize: 21,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
