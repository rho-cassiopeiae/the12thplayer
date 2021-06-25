import 'dart:ui';

import 'package:either_option/either_option.dart';

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

  PolicyExecutor<AuthenticationTokenExpiredError> _wsApiPolicy;

  final Map<String, Color> _usernameToColor = {};

  DiscussionService(
    this._storage,
    this._discussionApiService,
    this._accountService,
  ) {
    _wsApiPolicy = Policy.on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: _accountService.refreshAccessToken,
        ),
      ],
    );
  }

  Future<Either<Error, FixtureDiscussionsVm>> loadDiscussions(
    int fixtureId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var fixtureDiscussions =
          await _discussionApiService.getDiscussionsForFixture(
        fixtureId,
        currentTeam.id,
      );

      return Right(FixtureDiscussionsVm.fromDto(fixtureDiscussions));
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Stream<Either<Error, List<DiscussionEntryVm>>> loadDiscussion(
    int fixtureId,
    String discussionIdentifier,
  ) async* {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      _storage.clearDiscussionEntries();

      await for (var update
          in await _discussionApiService.subscribeToDiscussion(
        fixtureId,
        currentTeam.id,
        discussionIdentifier,
      )) {
        var entries = update.entries
            .map((entry) => DiscussionEntryVm.fromDto(entry, _usernameToColor))
            .toList();

        _storage.addDiscussionEntries(entries);

        yield Right(_storage.getDiscussionEntries());
      }
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      yield Left(Error(error.toString()));
    }
  }

  Future<Either<Error, List<DiscussionEntryVm>>> loadMoreDiscussionEntries(
    int fixtureId,
    String discussionIdentifier,
    String lastReceivedEntryId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var entryDtos = await _discussionApiService.getMoreDiscussionEntries(
        fixtureId,
        currentTeam.id,
        discussionIdentifier,
        lastReceivedEntryId,
      );

      var entryVms = entryDtos
          .map((entry) => DiscussionEntryVm.fromDto(entry, _usernameToColor))
          .toList();

      _storage.addDiscussionEntries(entryVms);

      return Right(_storage.getDiscussionEntries());
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  void unsubscribeFromDiscussion(
    int fixtureId,
    String discussionIdentifier,
  ) async {
    var currentTeam = await _storage.loadCurrentTeam();

    _discussionApiService.unsubscribeFromDiscussion(
      fixtureId,
      currentTeam.id,
      discussionIdentifier,
    );
  }

  Future<Option<Error>> postDiscussionEntry(
    int fixtureId,
    String discussionIdentifier,
    String body,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      await _wsApiPolicy.execute(
        () => _discussionApiService.postDiscussionEntry(
          fixtureId,
          currentTeam.id,
          discussionIdentifier,
          body,
        ),
      );

      return None();
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Some(Error(error.toString()));
    }
  }
}
