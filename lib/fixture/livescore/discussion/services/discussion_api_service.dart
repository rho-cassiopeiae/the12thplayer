import 'dart:async';

import 'package:signalr_core/signalr_core.dart';

import '../models/dto/fixture_discussions_dto.dart';
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
import '../../../../general/errors/api_error.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/errors/forbidden_error.dart';
import '../../../../general/errors/invalid_authentication_token_error.dart';
import '../../../../general/errors/validation_error.dart';
import '../../../../general/services/server_connector.dart';

class DiscussionApiService implements IDiscussionApiService {
  final ServerConnector _serverConnector;
  final SubscriptionTracker _subscriptionTracker;

  HubConnection get _connection => _serverConnector.connection;

  final Map<String, StreamController<FixtureDiscussionUpdateDto>>
      _discussionIdentifierToUpdatesChannel = {};

  DiscussionApiService(
    this._serverConnector,
    this._subscriptionTracker,
  ) {
    _serverConnector.message$
        .where((message) => message.item1 == enums.MessageType.DiscussionUpdate)
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
    }

    print(ex);

    return ApiError();
  }

  @override
  Future<FixtureDiscussionsDto> getDiscussionsForFixture(
    int fixtureId,
    int teamId,
  ) async {
    await _serverConnector.ensureConnected();

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

      return FixtureDiscussionsDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  void _updateDiscussion(List<dynamic> args) {
    var update = FixtureDiscussionUpdateDto.fromMap(args[0]);
    var discussionFullIdentifier =
        'fixture:${update.fixtureId}.team:${update.teamId}.discussion:${update.discussionIdentifier}';
    if (_discussionIdentifierToUpdatesChannel.containsKey(
      discussionFullIdentifier,
    )) {
      _discussionIdentifierToUpdatesChannel[discussionFullIdentifier]
          .add(update);
    }
  }

  @override
  Future<Stream<FixtureDiscussionUpdateDto>> subscribeToDiscussion(
    int fixtureId,
    int teamId,
    String discussionIdentifier,
  ) async {
    await _serverConnector.ensureConnected();

    var discussionFullIdentifier =
        'fixture:$fixtureId.team:$teamId.discussion:$discussionIdentifier';

    _subscriptionTracker.addSubscription(discussionFullIdentifier);

    var updatesChannel = StreamController<FixtureDiscussionUpdateDto>();
    _discussionIdentifierToUpdatesChannel[discussionFullIdentifier] =
        updatesChannel;

    try {
      var result = await _connection.invoke(
        'SubscribeToDiscussion',
        args: [
          SubscribeToDiscussionRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            discussionIdentifier: discussionIdentifier,
          ),
        ],
      );

      var discussion = FixtureDiscussionUpdateDto.fromMap(result['data']);

      updatesChannel.add(discussion);
      if (!discussion.shouldSubscribe) {
        _subscriptionTracker.removeSubscription(discussionFullIdentifier);
      }

      return updatesChannel.stream;
    } on Exception catch (ex) {
      _subscriptionTracker.removeSubscription(discussionFullIdentifier);
      updatesChannel.close();
      _discussionIdentifierToUpdatesChannel.remove(discussionFullIdentifier);

      throw _wrapHubException(ex);
    }
  }

  @override
  Future<Iterable<DiscussionEntryDto>> getMoreDiscussionEntries(
    int fixtureId,
    int teamId,
    String discussionIdentifier,
    String lastReceivedEntryId,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      var result = await _connection.invoke(
        'GetMoreDiscussionEntries',
        args: [
          GetMoreDiscussionEntriesRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            discussionIdentifier: discussionIdentifier,
            lastReceivedEntryId: lastReceivedEntryId,
          ),
        ],
      );

      return (result['data'] as List<dynamic>)
          .map((entryMap) => DiscussionEntryDto.fromMap(entryMap));
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  void unsubscribeFromDiscussion(
    int fixtureId,
    int teamId,
    String discussionIdentifier,
  ) async {
    await _serverConnector.ensureConnected();

    var discussionFullIdentifier =
        'fixture:$fixtureId.team:$teamId.discussion:$discussionIdentifier';

    _subscriptionTracker.removeSubscription(discussionFullIdentifier);

    var updatesChannel = _discussionIdentifierToUpdatesChannel.remove(
      discussionFullIdentifier,
    );
    if (updatesChannel != null) {
      updatesChannel.close();

      await _connection.invoke(
        'UnsubscribeFromDiscussion',
        args: [
          UnsubscribeFromDiscussionRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            discussionIdentifier: discussionIdentifier,
          ),
        ],
      );
    }
  }

  @override
  Future postDiscussionEntry(
    int fixtureId,
    int teamId,
    String discussionIdentifier,
    String body,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      await _connection.invoke(
        'PostDiscussionEntry',
        args: [
          PostDiscussionEntryRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            discussionIdentifier: discussionIdentifier,
            body: body,
          ),
        ],
      );
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }
}
