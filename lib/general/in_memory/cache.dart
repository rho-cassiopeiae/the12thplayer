import '../../match_predictions/models/vm/active_season_round_with_fixtures_vm.dart';
import '../../feed/models/vm/article_comments_vm.dart';
import '../../feed/models/vm/feed_articles_vm.dart';
import '../../fixture/livescore/video_reaction/models/vm/fixture_video_reactions_vm.dart';
import '../../fixture/livescore/discussion/models/vm/discussion_entry_vm.dart';
import '../../team/models/entities/team_entity.dart';
import '../../account/models/entities/account_entity.dart';

class Cache {
  AccountEntity _account;
  AccountEntity loadAccount() => _account;
  void saveAccount(AccountEntity account) => _account = account;

  TeamEntity _currentTeam;
  TeamEntity loadCurrentTeam() => _currentTeam;
  void saveCurrentTeam(TeamEntity team) => _currentTeam = team;

  final List<DiscussionEntryVm> _discussionEntries = [];

  void clearDiscussionEntries() => _discussionEntries.clear();

  void addDiscussionEntries(List<DiscussionEntryVm> entries) {
    entries.removeWhere(
      (entry) => _discussionEntries.indexWhere((e) => e.id == entry.id) >= 0,
    );

    _discussionEntries.addAll(entries);
    _discussionEntries.sort((e1, e2) {
      var e1IdSplit = e1.id.split('-');
      var e2IdSplit = e2.id.split('-');
      var c = int.parse(e1IdSplit[0]).compareTo(int.parse(e2IdSplit[0]));

      return c != 0
          ? c
          : int.parse(e1IdSplit[1]).compareTo(int.parse(e2IdSplit[1]));
    });
  }

  List<DiscussionEntryVm> getDiscussionEntries() => _discussionEntries;

  FixtureVideoReactionsVm _fixtureVideoReactions = FixtureVideoReactionsVm(
    page: 1,
    totalPages: 1,
    videoReactions: [],
  );

  void clearVideoReactions() =>
      _fixtureVideoReactions = FixtureVideoReactionsVm(
        page: 1,
        totalPages: 1,
        videoReactions: [],
      );

  void setVideoReactions(FixtureVideoReactionsVm fixtureVideoReactions) =>
      _fixtureVideoReactions = fixtureVideoReactions;

  void addVideoReactions(FixtureVideoReactionsVm fixtureVideoReactions) {
    if (fixtureVideoReactions.page == 1) {
      _fixtureVideoReactions = fixtureVideoReactions;
    } else {
      _fixtureVideoReactions = FixtureVideoReactionsVm(
        page: fixtureVideoReactions.page,
        totalPages: fixtureVideoReactions.totalPages,
        videoReactions: _fixtureVideoReactions.videoReactions.toList()
          ..addAll(fixtureVideoReactions.videoReactions),
      );
    }
  }

  FixtureVideoReactionsVm getVideoReactions() => _fixtureVideoReactions;

  FeedArticlesVm _feedArticles = FeedArticlesVm(
    page: 1,
    articles: [],
  );

  void setFeedArticles(FeedArticlesVm feedArticles) =>
      _feedArticles = feedArticles;

  void addFeedArticles(FeedArticlesVm feedArticles) {
    if (feedArticles.page == 1) {
      _feedArticles = feedArticles;
    } else {
      feedArticles.articles.removeWhere(
        (article) =>
            _feedArticles.articles.indexWhere((a) => a.id == article.id) >= 0,
      );
      if (feedArticles.articles.isNotEmpty) {
        _feedArticles = FeedArticlesVm(
          page: feedArticles.page,
          articles: _feedArticles.articles.toList()
            ..addAll(feedArticles.articles),
        );
      }
    }
  }

  FeedArticlesVm getFeedArticles() => _feedArticles;

  ArticleCommentsVm _articleComments = ArticleCommentsVm(
    articleId: null,
    comments: [],
  );

  void setArticleComments(ArticleCommentsVm articleComments) =>
      _articleComments = articleComments;

  ArticleCommentsVm getArticleComments() => _articleComments;

  ActiveSeasonRoundWithFixturesVm _seasonRound;
  Map<int, String> _draftPredictions = {};

  void setActiveSeasonRound(ActiveSeasonRoundWithFixturesVm seasonRound) =>
      _seasonRound = seasonRound;

  ActiveSeasonRoundWithFixturesVm getActiveSeasonRound() => _seasonRound;

  void clearDraftPredictions() => _draftPredictions = {};

  void addDraftPrediction(int fixtureId, String score) =>
      _draftPredictions[fixtureId] = score;

  Map<int, String> getDraftPredictions() => _draftPredictions;
}
