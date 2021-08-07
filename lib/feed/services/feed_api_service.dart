import 'dart:async';

import 'package:signalr_core/signalr_core.dart';

import '../interfaces/ifeed_api_service.dart';
import '../models/dto/requests/subscribe_to_team_feed_request_dto.dart';
import '../models/dto/team_feed_update_dto.dart';
import '../../../../general/errors/api_error.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/errors/forbidden_error.dart';
import '../../../../general/errors/invalid_authentication_token_error.dart';
import '../../../../general/errors/validation_error.dart';
import '../../../../general/services/server_connector.dart';
import '../../../../general/services/subscription_tracker.dart';
import '../../../../general/enums/message_type.dart' as enums;

class FeedApiService implements IFeedApiService {
  final ServerConnector _serverConnector;
  final SubscriptionTracker _subscriptionTracker;

  HubConnection get _connection => _serverConnector.connection;

  final Map<String, StreamController<TeamFeedUpdateDto>>
      _teamIdentifierToUpdatesChannel = {};

  FeedApiService(
    this._serverConnector,
    this._subscriptionTracker,
  ) {
    _serverConnector.message$
        .where((message) => message.item1 == enums.MessageType.FeedUpdate)
        .listen((message) {
      _updateFeed(message.item2);
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
    }

    print(ex);

    return ApiError();
  }

  void _updateFeed(List<dynamic> args) {
    var update = TeamFeedUpdateDto.fromMap(args[0]);
    var teamIdentifier = 'team:${update.teamId}';
    if (_teamIdentifierToUpdatesChannel.containsKey(teamIdentifier)) {
      _teamIdentifierToUpdatesChannel[teamIdentifier].add(update);
    }
  }

  @override
  Future<Stream<TeamFeedUpdateDto>> subscribeToTeamFeed(int teamId) async {
    await _serverConnector.ensureConnected();

    var teamIdentifier = 'team:$teamId';

    _subscriptionTracker.addSubscription(teamIdentifier);

    var updatesChannel = StreamController<TeamFeedUpdateDto>();
    _teamIdentifierToUpdatesChannel[teamIdentifier] = updatesChannel;

    try {
      var result = await _connection.invoke(
        'SubscribeToTeamFeed',
        args: [
          SubscribeToTeamFeedRequestDto(
            teamId: teamId,
          ),
        ],
      );

      var update = TeamFeedUpdateDto.fromMap(result['data']);
      updatesChannel.add(update);

      return updatesChannel.stream;
    } on Exception catch (ex) {
      _subscriptionTracker.removeSubscription(teamIdentifier);
      updatesChannel.close();
      _teamIdentifierToUpdatesChannel.remove(teamIdentifier);

      throw _wrapHubException(ex);
    }
  }
}
