import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../widgets/article_preview.dart';
import '../../account/bloc/account_actions.dart';
import '../../account/bloc/account_bloc.dart';
import '../../account/bloc/account_states.dart';
import '../../account/enums/account_type.dart';
import '../../account/pages/auth_page.dart';
import '../../general/widgets/sweet_sheet.dart';
import '../enums/article_filter.dart';
import '../../general/widgets/app_drawer.dart';
import 'article_type_selection_page.dart';
import '../bloc/feed_actions.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_states.dart';
import '../../general/extensions/kiwi_extension.dart';

class FeedPage extends StatefulWidget
    with DependencyResolver2<FeedBloc, AccountBloc> {
  static const routeName = '/feed';

  const FeedPage({Key key}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState(resolve1(), resolve2());
}

class _FeedPageState extends State<FeedPage> {
  final FeedBloc _feedBloc;
  final AccountBloc _accountBloc;

  final SweetSheet _sweetSheet = SweetSheet();

  ArticleFilter _filter;
  RefreshController _refreshController;

  _FeedPageState(
    this._feedBloc,
    this._accountBloc,
  );

  @override
  void initState() {
    super.initState();

    _filter = ArticleFilter.Newest;
    _refreshController = RefreshController();

    _loadArticles(page: 1);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<LoadArticlesState> _loadArticles({@required int page}) {
    var action = LoadArticles(
      filter: _filter,
      page: page,
    );
    _feedBloc.dispatchAction(action);

    return action.state;
  }

  Future<bool> _showAuthDialogIfNecessary() async {
    var action = LoadAccount();
    _accountBloc.dispatchAction(action);

    var state = await action.state;
    if (state is AccountError) {
      return false;
    }

    var account = (state as AccountReady).account;
    if (account.type == AccountType.Guest) {
      bool goToAuthPage = await _sweetSheet.show<bool>(
        context: context,
        title: Text('Not authenticated'),
        description: Text('Authenticate to continue'),
        color: SweetSheetColor.WARNING,
        positive: SweetSheetAction(
          onPressed: () => Navigator.of(context).pop(true),
          title: 'SIGN-UP/IN/CONFIRM',
          icon: Icons.login,
        ),
        negative: SweetSheetAction(
          onPressed: () => Navigator.of(context).pop(false),
          title: 'CANCEL',
        ),
      );

      if (goToAuthPage ?? false) {
        Navigator.of(context).pushNamed(
          AuthPage.routeName,
          arguments: true,
        );
      }

      return false;
    }

    return true;
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
            onPressed: () => _loadArticles(page: 1),
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              bool canProceed = await _showAuthDialogIfNecessary();
              if (canProceed) {
                Navigator.of(context).pushNamed(
                  ArticleTypeSelectionPage.routeName,
                );
              }
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<LoadArticlesState>(
        initialData: ArticlesLoading(),
        stream: _feedBloc.feedArticlesState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is ArticlesLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var feedArticles = (state as ArticlesReady).feedArticles;
          var articles = feedArticles.articles;

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
                  height: 50.0,
                  child: Center(child: widget),
                );
              },
            ),
            controller: _refreshController,
            onLoading: () async {
              await _loadArticles(page: feedArticles.page + 1);
              _refreshController.loadComplete();
            },
            enablePullDown: false,
            enablePullUp: true,
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return ArticlePreview(
                  article: articles[index],
                  index: index,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
