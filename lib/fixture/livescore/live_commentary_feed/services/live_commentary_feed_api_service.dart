import 'dart:async';

import 'package:signalr_core/signalr_core.dart';

import '../../../../general/services/subscription_tracker.dart';
import '../../../../general/enums/message_type.dart' as enums;
import '../models/dto/requests/unsubscribe_from_live_commentary_feed_request_dto.dart';
import '../enums/live_commentary_feed_vote_action.dart';
import '../models/dto/fixture_live_commentary_feed_update_dto.dart';
import '../models/dto/requests/subscribe_to_live_commentary_feed_request_dto.dart';
import '../models/dto/requests/vote_for_live_commentary_feed_request_dto.dart';
import '../enums/live_commentary_filter.dart';
import '../errors/live_commentary_feed_error.dart';
import '../interfaces/ilive_commentary_feed_api_service.dart';
import '../models/dto/fixture_live_commentary_feeds_dto.dart';
import '../models/dto/requests/get_live_commentary_feeds_for_fixture_request_dto.dart';
import '../../../../general/errors/api_error.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/errors/forbidden_error.dart';
import '../../../../general/errors/invalid_authentication_token_error.dart';
import '../../../../general/errors/validation_error.dart';
import '../../../../general/services/server_connector.dart';

class LiveCommentaryFeedApiService implements ILiveCommentaryFeedApiService {
  final ServerConnector _serverConnector;
  final SubscriptionTracker _subscriptionTracker;

  HubConnection get _connection => _serverConnector.connection;

  final Map<String, StreamController<FixtureLiveCommentaryFeedUpdateDto>>
      _liveCommFeedIdentifierToUpdatesChannel = {};

  LiveCommentaryFeedApiService(
    this._serverConnector,
    this._subscriptionTracker,
  ) {
    _serverConnector.message$
        .where((message) =>
            message.item1 == enums.MessageType.LiveCommentaryFeedUpdate)
        .listen((message) {
      _updateLiveCommentaryFeed(message.item2);
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
    } else if (errorMessage.contains('[LiveCommentaryError]')) {
      return LiveCommentaryFeedError(
        errorMessage.split('[LiveCommentaryError] ').last,
      );
    }

    print(ex);

    return ApiError();
  }

  @override
  Future<FixtureLiveCommentaryFeedsDto> getLiveCommentaryFeedsForFixture(
    int fixtureId,
    int teamId,
    LiveCommentaryFilter filter,
    int start,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      var result = await _connection.invoke(
        'GetLiveCommentaryFeedsForFixture',
        args: [
          GetLiveCommentaryFeedsForFixtureRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            filter: filter,
            start: start,
          ),
        ],
      );

      return FixtureLiveCommentaryFeedsDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<int> voteForLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
    LiveCommentaryFeedVoteAction voteAction,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      var result = await _connection.invoke(
        'VoteForLiveCommentaryFeed',
        args: [
          VoteForLiveCommentaryFeedRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            authorId: authorId,
            voteAction: voteAction,
          ),
        ],
      );

      return result['data']['updatedRating'];
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  void _updateLiveCommentaryFeed(List<dynamic> args) {
    var update = FixtureLiveCommentaryFeedUpdateDto.fromMap(args[0]);
    var liveCommFeedIdentifier =
        'fixture:${update.fixtureId}.team:${update.teamId}.author:${update.authorId}';
    if (_liveCommFeedIdentifierToUpdatesChannel.containsKey(
      liveCommFeedIdentifier,
    )) {
      _liveCommFeedIdentifierToUpdatesChannel[liveCommFeedIdentifier]
          .add(update);
    }
  }

  @override
  Future<Stream<FixtureLiveCommentaryFeedUpdateDto>>
      subscribeToLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
    String lastReceivedEntryId,
  ) async {
    await _serverConnector.ensureConnected();

    var liveCommFeedIdentifier =
        'fixture:$fixtureId.team:$teamId.author:$authorId';

    _subscriptionTracker.addSubscription(liveCommFeedIdentifier);

    var updatesChannel = StreamController<FixtureLiveCommentaryFeedUpdateDto>();
    _liveCommFeedIdentifierToUpdatesChannel[liveCommFeedIdentifier] =
        updatesChannel;

    try {
      var result = await _connection.invoke(
        'SubscribeToLiveCommentaryFeed',
        args: [
          SubscribeToLiveCommentaryFeedRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            authorId: authorId,
            lastReceivedEntryId: lastReceivedEntryId,
          ),
        ],
      );

      updatesChannel.add(
        FixtureLiveCommentaryFeedUpdateDto.fromMap(result['data']),
      );

      return updatesChannel.stream;
    } on Exception catch (ex) {
      _subscriptionTracker.removeSubscription(liveCommFeedIdentifier);
      updatesChannel.close();
      _liveCommFeedIdentifierToUpdatesChannel.remove(liveCommFeedIdentifier);

      throw _wrapHubException(ex);
    }
  }

  @override
  void unsubscribeFromLiveCommentaryFeed(
    int fixtureId,
    int teamId,
    int authorId,
  ) async {
    await _serverConnector.ensureConnected();

    var liveCommFeedIdentifier =
        'fixture:$fixtureId.team:$teamId.author:$authorId';
    _subscriptionTracker.removeSubscription(liveCommFeedIdentifier);

    var updatesChannel = _liveCommFeedIdentifierToUpdatesChannel.remove(
      liveCommFeedIdentifier,
    );
    if (updatesChannel != null) {
      updatesChannel.close();

      await _connection.invoke(
        'UnsubscribeFromLiveCommentaryFeed',
        args: [
          UnsubscribeFromLiveCommentaryFeedRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            authorId: authorId,
          ),
        ],
      );
    }
  }
}
