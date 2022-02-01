import '../../match_predictions/models/vm/active_season_round_with_fixtures_vm.dart';
import '../../feed/models/vm/article_comments_vm.dart';
import '../../feed/models/vm/feed_articles_vm.dart';
import '../../fixture/livescore/video_reaction/models/vm/fixture_video_reactions_vm.dart';
import '../../fixture/livescore/player_rating/interfaces/iplayer_rating_repository.dart';
import '../../fixture/livescore/player_rating/models/entities/fixture_player_ratings_entity.dart';
import '../../fixture/livescore/discussion/models/vm/discussion_entry_vm.dart';
import '../../fixture/livescore/interfaces/ifixture_repository.dart';
import '../../fixture/calendar/interfaces/ifixture_calendar_repository.dart';
import '../../fixture/common/models/entities/fixture_entity.dart';
import '../../team/interfaces/iteam_repository.dart';
import '../../team/models/entities/team_entity.dart';
import '../../account/interfaces/iaccount_repository.dart';
import '../../account/models/entities/account_entity.dart';
import '../in_memory/cache.dart';

class Storage {
  final Cache _cache;
  final IAccountRepository _accountRepository;
  final ITeamRepository _teamRepository;
  final IFixtureCalendarRepository _fixtureCalendarRepository;
  final IFixtureRepository _fixtureRepository;
  final IPlayerRatingRepository _playerRatingRepository;

  Storage(
    this._cache,
    this._accountRepository,
    this._teamRepository,
    this._fixtureCalendarRepository,
    this._fixtureRepository,
    this._playerRatingRepository,
  );

  Future<AccountEntity> loadAccount() async {
    var account = _cache.loadAccount();
    if (account == null) {
      account = await _accountRepository.loadAccount();
      _cache.saveAccount(account);
    }

    return account;
  }

  Future saveAccount(AccountEntity account) async {
    await _accountRepository.saveAccount(account);
    _cache.saveAccount(account);
  }

  Future<TeamEntity> loadCurrentTeam() async {
    var team = _cache.loadCurrentTeam();
    if (team == null) {
      team = await _teamRepository.loadCurrentTeam();
      if (team != null) {
        _cache.saveCurrentTeam(team);
      }
    }

    return team;
  }

  Future<Iterable<FixtureEntity>> loadFixturesForTeamInBetween(
    int teamId,
    DateTime startTime,
    DateTime endTime,
  ) =>
      _fixtureCalendarRepository.loadFixturesForTeamInBetween(
        teamId,
        startTime,
        endTime,
      );

  Future saveFixtures(Iterable<FixtureEntity> fixtures) =>
      _fixtureCalendarRepository.saveFixtures(fixtures);

  Future<FixtureEntity> loadFixtureForTeam(int fixtureId, int teamId) =>
      _fixtureRepository.loadFixtureForTeam(fixtureId, teamId);

  Future updateFixture(FixtureEntity fixture) =>
      _fixtureRepository.updateFixture(fixture);

  Future<FixtureEntity> updateFixtureFromLivescore(FixtureEntity fixture) =>
      _fixtureRepository.updateFixtureFromLivescore(fixture);

  void clearDiscussionEntries() => _cache.clearDiscussionEntries();

  void addDiscussionEntries(List<DiscussionEntryVm> entries) =>
      _cache.addDiscussionEntries(entries);

  List<DiscussionEntryVm> getDiscussionEntries() =>
      _cache.getDiscussionEntries();

  Future<FixturePlayerRatingsEntity> loadPlayerRatingsForFixture(
    int fixtureId,
    int teamId,
  ) =>
      _playerRatingRepository.loadPlayerRatingsForFixture(
        fixtureId,
        teamId,
      );

  Future savePlayerRatingsForFixture(
    FixturePlayerRatingsEntity fixturePlayerRatings,
  ) =>
      _playerRatingRepository.savePlayerRatingsForFixture(fixturePlayerRatings);

  Future<FixturePlayerRatingsEntity> updatePlayerRating(
    int fixtureId,
    int teamId,
    String participantKey,
    int totalRating,
    int totalVoters,
    double userRating,
  ) =>
      _playerRatingRepository.updatePlayerRating(
        fixtureId,
        teamId,
        participantKey,
        totalRating,
        totalVoters,
        userRating,
      );

  void clearVideoReactions() => _cache.clearVideoReactions();

  void setVideoReactions(FixtureVideoReactionsVm fixtureVideoReactions) =>
      _cache.setVideoReactions(fixtureVideoReactions);

  void addVideoReactions(FixtureVideoReactionsVm fixtureVideoReactions) =>
      _cache.addVideoReactions(fixtureVideoReactions);

  FixtureVideoReactionsVm getVideoReactions() => _cache.getVideoReactions();

  void setFeedArticles(FeedArticlesVm feedArticles) =>
      _cache.setFeedArticles(feedArticles);

  void addFeedArticles(FeedArticlesVm feedArticles) =>
      _cache.addFeedArticles(feedArticles);

  FeedArticlesVm getFeedArticles() => _cache.getFeedArticles();

  void setArticleComments(ArticleCommentsVm articleComments) =>
      _cache.setArticleComments(articleComments);

  ArticleCommentsVm getArticleComments() => _cache.getArticleComments();

  void setActiveSeasonRound(ActiveSeasonRoundWithFixturesVm seasonRound) =>
      _cache.setActiveSeasonRound(seasonRound);

  ActiveSeasonRoundWithFixturesVm getActiveSeasonRound() =>
      _cache.getActiveSeasonRound();

  void clearDraftPredictions() => _cache.clearDraftPredictions();

  void addDraftPrediction(int fixtureId, String score) =>
      _cache.addDraftPrediction(fixtureId, score);

  Map<int, String> getDraftPredictions() => _cache.getDraftPredictions();
}
