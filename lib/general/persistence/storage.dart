import '../../fixture/livescore/live_commentary_recording/enums/live_commentary_recording_entry_status.dart';
import '../../fixture/livescore/live_commentary_recording/enums/live_commentary_recording_status.dart';
import '../../fixture/livescore/live_commentary_recording/models/entities/live_commentary_recording_entry_entity.dart';
import '../../fixture/livescore/discussion/models/vm/discussion_entry_vm.dart';
import '../../fixture/livescore/live_commentary_recording/interfaces/ilive_commentary_recording_repository.dart';
import '../../fixture/livescore/live_commentary_recording/models/entities/live_commentary_recording_entity.dart';
import '../../fixture/livescore/live_commentary_feed/models/entities/live_commentary_feed_entry_entity.dart';
import '../../fixture/livescore/live_commentary_feed/models/entities/live_commentary_feed_entity.dart';
import '../../fixture/livescore/live_commentary_feed/enums/live_commentary_feed_vote_action.dart';
import '../../fixture/livescore/live_commentary_feed/interfaces/ilive_commentary_feed_repository.dart';
import '../../fixture/livescore/live_commentary_feed/models/entities/fixture_live_commentary_feed_votes_entity.dart';
import '../../fixture/livescore/interfaces/ifixture_repository.dart';
import '../../fixture/calendar/interfaces/ifixture_calendar_repository.dart';
import '../../fixture/common/models/entities/fixture_entity.dart';
import '../interfaces/iteam_repository.dart';
import '../models/entities/team_entity.dart';
import '../../account/interfaces/iaccount_repository.dart';
import '../../account/models/entities/account_entity.dart';
import '../in_memory/cache.dart';

class Storage {
  final Cache _cache;
  final IAccountRepository _accountRepository;
  final ITeamRepository _teamRepository;
  final IFixtureCalendarRepository _fixtureCalendarRepository;
  final IFixtureRepository _fixtureRepository;
  final ILiveCommentaryFeedRepository _liveCommentaryFeedRepository;
  final ILiveCommentaryRecordingRepository _liveCommentaryRecordingRepository;

  Storage(
    this._cache,
    this._accountRepository,
    this._teamRepository,
    this._fixtureCalendarRepository,
    this._fixtureRepository,
    this._liveCommentaryFeedRepository,
    this._liveCommentaryRecordingRepository,
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
      _cache.saveCurrentTeam(team);
    }

    return team;
  }

  Future<Iterable<FixtureEntity>> loadFixturesForTeamInBetween(
    int teamId,
    DateTime startTime,
    DateTime endTime,
  ) {
    return _fixtureCalendarRepository.loadFixturesForTeamInBetween(
      teamId,
      startTime,
      endTime,
    );
  }

  Future saveFixtures(Iterable<FixtureEntity> fixtures) {
    return _fixtureCalendarRepository.saveFixtures(fixtures);
  }

  Future<FixtureEntity> loadFixtureForTeam(int fixtureId, int teamId) {
    return _fixtureRepository.loadFixtureForTeam(fixtureId, teamId);
  }

  Future<FixtureEntity> updateFixture(FixtureEntity fixture) {
    return _fixtureRepository.updateFixture(fixture);
  }

  Future<FixtureEntity> updateFixtureFromLivescore(
    FixtureEntity fixture,
  ) {
    return _fixtureRepository.updateFixtureFromLivescore(fixture);
  }

  Future<double> updateMyRatingOfParticipantOfGivenFixture(
    int fixtureId,
    int teamId,
    String participantIdentifier,
    double rating,
  ) {
    return _fixtureRepository.updateMyRatingOfParticipantOfGivenFixture(
      fixtureId,
      teamId,
      participantIdentifier,
      rating,
    );
  }

  Future updateRatingOfParticipantOfGivenFixture(
    int fixtureId,
    int teamId,
    String participantIdentifier,
    int totalRating,
    int totalVoters,
  ) {
    return _fixtureRepository.updateRatingOfParticipantOfGivenFixture(
      fixtureId,
      teamId,
      participantIdentifier,
      totalRating,
      totalVoters,
    );
  }

  Future<FixtureLiveCommentaryFeedVotesEntity>
      loadLiveCommentaryFeedVotesForFixture(
    int fixtureId,
    int teamId,
  ) {
    return _liveCommentaryFeedRepository.loadLiveCommentaryFeedVotesForFixture(
      fixtureId,
      teamId,
    );
  }

  Future<LiveCommentaryFeedVoteAction> updateVoteActionForLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
    LiveCommentaryFeedVoteAction voteAction,
  ) {
    return _liveCommentaryFeedRepository.updateVoteActionForLiveCommentaryFeed(
      fixtureId,
      teamId,
      authorId,
      voteAction,
    );
  }

  Future<LiveCommentaryFeedEntity> loadLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
  ) {
    return _liveCommentaryFeedRepository.loadLiveCommentaryFeed(
      fixtureId,
      teamId,
      authorId,
    );
  }

  Future addLiveCommentaryFeedEntries(
    Iterable<LiveCommentaryFeedEntryEntity> entries,
  ) {
    return _liveCommentaryFeedRepository.addLiveCommentaryFeedEntries(entries);
  }

  void clearDiscussionEntries() => _cache.clearDiscussionEntries();

  void addDiscussionEntries(List<DiscussionEntryVm> entries) =>
      _cache.addDiscussionEntries(entries);

  List<DiscussionEntryVm> getDiscussionEntries() =>
      _cache.getDiscussionEntries();

  Future<LiveCommentaryRecordingEntity> loadLiveCommentaryRecordingOfFixture(
    int fixtureId,
    int teamId,
  ) {
    return _liveCommentaryRecordingRepository
        .loadLiveCommentaryRecordingOfFixture(
      fixtureId,
      teamId,
    );
  }

  Future renameLiveCommentaryRecordingOfFixture(
    int fixtureId,
    int teamId,
    String name,
  ) {
    return _liveCommentaryRecordingRepository
        .renameLiveCommentaryRecordingOfFixture(
      fixtureId,
      teamId,
      name,
    );
  }

  Future<LiveCommentaryRecordingEntity>
      loadLiveCommentaryRecordingNameAndStatus(
    int fixtureId,
    int teamId,
  ) {
    return _liveCommentaryRecordingRepository
        .loadLiveCommentaryRecordingNameAndStatus(
      fixtureId,
      teamId,
    );
  }

  Future updateLiveCommentaryRecordingStatus(
    int fixtureId,
    int teamId,
    LiveCommentaryRecordingStatus status,
  ) {
    return _liveCommentaryRecordingRepository
        .updateLiveCommentaryRecordingStatus(
      fixtureId,
      teamId,
      status,
    );
  }

  Future addLiveCommentaryRecordingEntry(
    LiveCommentaryRecordingEntryEntity entry,
  ) {
    return _liveCommentaryRecordingRepository
        .addLiveCommentaryRecordingEntry(entry);
  }

  Future<Iterable<LiveCommentaryRecordingEntryEntity>>
      loadLiveCommentaryRecordingEntries(
    int fixtureId,
    int teamId,
  ) {
    return _liveCommentaryRecordingRepository
        .loadLiveCommentaryRecordingEntries(
      fixtureId,
      teamId,
    );
  }

  Future updateLiveCommentaryRecordingEntry(
    LiveCommentaryRecordingEntryEntity entry,
  ) {
    return _liveCommentaryRecordingRepository
        .updateLiveCommentaryRecordingEntry(entry);
  }

  Future<LiveCommentaryRecordingEntryStatus>
      loadPrevLiveCommentaryRecordingEntryStatus(
    int fixtureId,
    int teamId,
    int currentEntryPostedAt,
  ) {
    return _liveCommentaryRecordingRepository
        .loadPrevLiveCommentaryRecordingEntryStatus(
      fixtureId,
      teamId,
      currentEntryPostedAt,
    );
  }

  Future<Iterable<LiveCommentaryRecordingEntryEntity>>
      loadNotPublishedLiveCommentaryRecordingEntries(
    int fixtureId,
    int teamId,
  ) {
    return _liveCommentaryRecordingRepository
        .loadNotPublishedLiveCommentaryRecordingEntries(fixtureId, teamId);
  }

  Future updateLiveCommentaryRecordingEntries(
    Iterable<LiveCommentaryRecordingEntryEntity> entries,
  ) {
    return _liveCommentaryRecordingRepository
        .updateLiveCommentaryRecordingEntries(entries);
  }
}
