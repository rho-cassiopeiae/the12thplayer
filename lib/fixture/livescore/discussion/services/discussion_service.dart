import 'dart:math';
import 'dart:ui';

import 'package:either_option/either_option.dart';

import '../../../../general/services/notification_service.dart';
import '../../../../general/errors/connection_error.dart';
import '../../../../general/errors/server_error.dart';
import '../models/vm/fixture_discussions_vm.dart';
import '../../../../account/services/account_service.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/utils/policy.dart';
import '../interfaces/idiscussion_api_service.dart';
import '../models/vm/discussion_entry_vm.dart';
import '../../../../general/persistence/storage.dart';
import '../../../../general/errors/error.dart';

class DiscussionService {
  final Storage _storage;
  final IDiscussionApiService _discussionApiService;
  final AccountService _accountService;
  final NotificationService _notificationService;

  Policy _policy;

  final Map<int, Color> _userIdToColor = {};

  DiscussionService(
    this._storage,
    this._discussionApiService,
    this._accountService,
    this._notificationService,
  ) {
    _policy = PolicyBuilder().on<ConnectionError>(
      strategies: [
        When(
          any,
          repeat: 1,
          withInterval: (_) => Duration(milliseconds: 200),
        ),
      ],
    ).on<ServerError>(
      strategies: [
        When(
          any,
          repeat: 3,
          withInterval: (attempt) => Duration(
            milliseconds: 200 * pow(2, attempt),
          ),
        ),
      ],
    ).on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: _accountService.refreshAccessToken,
        ),
      ],
    ).build();
  }

  Future<Either<Error, FixtureDiscussionsVm>> loadDiscussions(
    int fixtureId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var discussions = await _policy.execute(
        () => _discussionApiService.getDiscussionsForFixture(
          fixtureId,
          currentTeam.id,
        ),
      );

      return Right(FixtureDiscussionsVm.fromDto(discussions));
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return Left(Error(error.toString()));
    }
  }

  Stream<Either<Error, List<DiscussionEntryVm>>> loadDiscussion(
    int fixtureId,
    String discussionId,
  ) async* {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      _storage.clearDiscussionEntries();

      var update$ = await _policy.execute(
        () => _discussionApiService.subscribeToDiscussion(
          fixtureId,
          currentTeam.id,
          discussionId,
        ),
      );

      await for (var update in update$) {
        var entries = update.entries
            .map((entry) => DiscussionEntryVm.fromDto(entry, _userIdToColor))
            .toList();

        _storage.addDiscussionEntries(entries);

        yield Right(_storage.getDiscussionEntries());
      }
    } catch (error) {
      _notificationService.showMessage(error.toString());
      yield Left(Error(error.toString()));
    }
  }

  Future<List<DiscussionEntryVm>> loadMoreDiscussionEntries(
    int fixtureId,
    String discussionId,
    String lastReceivedEntryId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var entryDtos = await _policy.execute(
        () => _discussionApiService.getMoreDiscussionEntries(
          fixtureId,
          currentTeam.id,
          discussionId,
          lastReceivedEntryId,
        ),
      );

      var entryVms = entryDtos
          .map((entry) => DiscussionEntryVm.fromDto(entry, _userIdToColor))
          .toList();

      _storage.addDiscussionEntries(entryVms);
    } catch (error) {
      _notificationService.showMessage(error.toString());
    }

    return _storage.getDiscussionEntries();
  }

  void unsubscribeFromDiscussion(int fixtureId, String discussionId) async {
    var currentTeam = await _storage.loadCurrentTeam();

    await _policy.execute(
      () => _discussionApiService.unsubscribeFromDiscussion(
        fixtureId,
        currentTeam.id,
        discussionId,
      ),
    );
  }

  Future<Option<Error>> postDiscussionEntry(
    int fixtureId,
    String discussionId,
    String body,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      await _policy.execute(
        () => _discussionApiService.postDiscussionEntry(
          fixtureId,
          currentTeam.id,
          discussionId,
          body,
        ),
      );

      return None();
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return Some(Error(error.toString()));
    }
  }
}
