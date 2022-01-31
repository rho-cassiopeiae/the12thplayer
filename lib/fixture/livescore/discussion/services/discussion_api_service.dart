import 'dart:async';

import 'package:signalr_core/signalr_core.dart';

import '../models/dto/discussion_dto.dart';
import '../../../../general/errors/server_error.dart';
import '../../errors/livescore_error.dart';
import '../models/dto/requests/get_discussions_for_fixture_request_dto.dart';
import '../../../../general/services/subscription_tracker.dart';
import '../../../../general/enums/message_type.dart' as enums;
import '../models/dto/discussion_entry_dto.dart';
import '../models/dto/requests/get_more_discussion_entries_request_dto.dart';
import '../models/dto/requests/post_discussion_entry_request_dto.dart';
import '../models/dto/requests/unsubscribe_from_discussion_request_dto.dart';
import '../errors/discussion_error.dart';
import '../interfaces/idiscussion_api_service.dart';
import '../models/dto/fixture_discussion_update_dto.dart';
import '../models/dto/requests/subscribe_to_discussion_request_dto.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/errors/forbidden_error.dart';
import '../../../../general/errors/invalid_authentication_token_error.dart';
import '../../../../general/errors/validation_error.dart';
import '../../../../general/services/server_connector.dart';

class DiscussionApiService implements IDiscussionApiService {
  final ServerConnector _serverConnector;
  final SubscriptionTracker _subscriptionTracker;

  HubConnection get _connection => _serverConnector.livescoreConnection;

  final Map<String, StreamController<FixtureDiscussionUpdateDto>>
      _discussionIdentifierToUpdatesChannel = {};

  DiscussionApiService(
    this._serverConnector,
    this._subscriptionTracker,
  ) {
    _serverConnector.message$
        .where((message) =>
            message.item1 == enums.MessageType.FixtureDiscussionUpdate)
        .listen((message) {
      _updateDiscussion(message.item2);
    });
  }

  dynamic _wrapHubException(Exception ex) {
    var errorMessage = ex.toString();
    if (errorMessage.contains('[AuthorizationError]')) {
      if (errorMessage.contains('Forbidden')) {
        return ForbiddenError();
      } else if (errorMessage.contains('token expired at')) {
        return AuthenticationTokenExpiredError();
      } else {
        return InvalidAuthenticationTokenError(
          errorMessage.split('[AuthorizationError] ').last,
        );
      }
    } else if (errorMessage.contains('[ValidationError]')) {
      return ValidationError();
    } else if (errorMessage.contains('[DiscussionError]')) {
      return DiscussionError(errorMessage.split('[DiscussionError] ').last);
    } else if (errorMessage.contains('[LivescoreError]')) {
      return LivescoreError(errorMessage.split('[LivescoreError] ').last);
    }

    print(ex);

    return ServerError();
  }

  @override
  Future<Iterable<DiscussionDto>> getDiscussionsForFixture(
    int fixtureId,
    int teamId,
  ) async {
    await _serverConnector.ensureLivescoreConnected();

    try {
      var result = await _connection.invoke(
        'GetDiscussionsForFixture',
        args: [
          GetDiscussionsForFixtureRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
          ),
        ],
      );

      return (result['data'] as List)
          .map((discussionMap) => DiscussionDto.fromMap(discussionMap));
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  void _updateDiscussion(List<dynamic> args) {
    var update = FixtureDiscussionUpdateDto.fromMap(args[0]);
    var discussionIdentifier =
        'f:${update.fixtureId}.t:${update.teamId}.d:${update.discussionId}';
    if (_discussionIdentifierToUpdatesChannel.containsKey(
      discussionIdentifier,
    )) {
      _discussionIdentifierToUpdatesChannel[discussionIdentifier].add(update);
    }
  }

  @override
  Future<Stream<FixtureDiscussionUpdateDto>> subscribeToDiscussion(
    int fixtureId,
    int teamId,
    String discussionId,
  ) async {
    await _serverConnector.ensureLivescoreConnected();

    var discussionIdentifier = 'f:$fixtureId.t:$teamId.d:$discussionId';

    _subscriptionTracker.addSubscription(discussionIdentifier);

    // ignore: close_sinks
    var updatesChannel = StreamController<FixtureDiscussionUpdateDto>();
    _discussionIdentifierToUpdatesChannel[discussionIdentifier] =
        updatesChannel;

    try {
      var result = await _connection.invoke(
        'SubscribeToDiscussion',
        args: [
          SubscribeToDiscussionRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            discussionId: discussionId,
          ),
        ],
      );

      var update = FixtureDiscussionUpdateDto.fromMap(result['data']);
      updatesChannel.add(update);

      return updatesChannel.stream;
    } on Exception catch (ex) {
      _subscriptionTracker.removeSubscription(discussionIdentifier);
      _discussionIdentifierToUpdatesChannel
          .remove(discussionIdentifier)
          .close();

      throw _wrapHubException(ex);
    }
  }

  @override
  Future<Iterable<DiscussionEntryDto>> getMoreDiscussionEntries(
    int fixtureId,
    int teamId,
    String discussionId,
    String lastReceivedEntryId,
  ) async {
    await _serverConnector.ensureLivescoreConnected();

    try {
      var result = await _connection.invoke(
        'GetMoreDiscussionEntries',
        args: [
          GetMoreDiscussionEntriesRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            discussionId: discussionId,
            lastReceivedEntryId: lastReceivedEntryId,
          ),
        ],
      );

      return (result['data'] as List)
          .map((entryMap) => DiscussionEntryDto.fromMap(entryMap));
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future unsubscribeFromDiscussion(
    int fixtureId,
    int teamId,
    String discussionId,
  ) async {
    await _serverConnector.ensureLivescoreConnected();

    var discussionIdentifier = 'f:$fixtureId.t:$teamId.d:$discussionId';

    _subscriptionTracker.removeSubscription(discussionIdentifier);

    var updatesChannel = _discussionIdentifierToUpdatesChannel.remove(
      discussionIdentifier,
    );
    if (updatesChannel != null) {
      updatesChannel.close();

      try {
        await _connection.invoke(
          'UnsubscribeFromDiscussion',
          args: [
            UnsubscribeFromDiscussionRequestDto(
              fixtureId: fixtureId,
              teamId: teamId,
              discussionId: discussionId,
            ),
          ],
        );
      } on Exception catch (ex) {
        throw _wrapHubException(ex);
      }
    }
  }

  @override
  Future postDiscussionEntry(
    int fixtureId,
    int teamId,
    String discussionId,
    String body,
  ) async {
    await _serverConnector.ensureLivescoreConnected();

    try {
      await _connection.invoke(
        'PostDiscussionEntry',
        args: [
          PostDiscussionEntryRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            discussionId: discussionId,
            body: body,
          ),
        ],
      );
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }
}
