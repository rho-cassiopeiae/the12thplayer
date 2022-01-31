import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:tuple/tuple.dart';

import '../errors/connection_error.dart';
import 'subscription_tracker.dart';
import '../enums/message_type.dart' as enums;
import '../models/dto/requests/add_to_groups_request_dto.dart';

class ServerConnector {
  final SubscriptionTracker _subscriptionTracker;

  HubConnection _livescoreConnection;
  Completer _livescoreConnected;

  HubConnection _feedConnection;
  Completer _feedConnected;

  Dio _dioIdentity;
  Dio _dioProfile;
  Dio _dioLivescore;
  Dio _dioFeed;
  Dio _dioVimeo;
  Dio _dioVimeoPlayer;
  Dio _dioMatchPredictions;

  String _accessToken;
  String _refreshToken;

  HubConnection get livescoreConnection => _livescoreConnection;
  HubConnection get feedConnection => _feedConnection;

  Dio get dioIdentity => _dioIdentity;
  Dio get dioProfile => _dioProfile;
  Dio get dioLivescore => _dioLivescore;
  Dio get dioFeed => _dioFeed;
  Dio get dioVimeo => _dioVimeo;
  Dio get dioVimeoPlayer => _dioVimeoPlayer;
  Dio get dioMatchPredictions => _dioMatchPredictions;

  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;

  // ignore: close_sinks
  final StreamController<Tuple2<enums.MessageType, List<dynamic>>>
      _messageChannel =
      StreamController<Tuple2<enums.MessageType, List<dynamic>>>.broadcast();

  Stream<Tuple2<enums.MessageType, List<dynamic>>> get message$ =>
      _messageChannel.stream;

  ServerConnector(this._subscriptionTracker) {
    _dioIdentity = Dio(
      BaseOptions(
        baseUrl: FlutterConfig.get('IDENTITY_API_BASE_URL'),
      ),
    );
    _dioProfile = Dio(
      BaseOptions(
        baseUrl: FlutterConfig.get('PROFILE_API_BASE_URL'),
      ),
    );
    _dioLivescore = Dio(
      BaseOptions(
        baseUrl: FlutterConfig.get('LIVESCORE_API_BASE_URL'),
      ),
    );
    _dioFeed = Dio(
      BaseOptions(
        baseUrl: FlutterConfig.get('FEED_API_BASE_URL'),
      ),
    );
    _dioVimeo = Dio(
      BaseOptions(
        baseUrl: FlutterConfig.get('VIMEO_API_BASE_URL'),
      ),
    );
    _dioVimeoPlayer = Dio(
      BaseOptions(
        baseUrl: FlutterConfig.get('VIMEO_PLAYER_API_BASE_URL'),
      ),
    );
    _dioMatchPredictions = Dio(
      BaseOptions(
        baseUrl: FlutterConfig.get('MATCH_PREDICTIONS_API_BASE_URL'),
      ),
    );
  }

  Future _connectToLivescore() async {
    _livescoreConnection = HubConnectionBuilder()
        .withUrl(
          '${FlutterConfig.get('LIVESCORE_API_BASE_URL')}/livescore/fanzone',
          HttpConnectionOptions(
            transport: HttpTransportType.webSockets,
            skipNegotiation: true,
            accessTokenFactory:
                _accessToken != null ? () => Future.value(_accessToken) : null,
            logging: (level, message) => print(
              '[livescore] [$level] $message',
            ), // @@TODO: Proper logging.
          ),
        )
        .build();

    _livescoreConnection.keepAliveIntervalInMilliseconds = 90 * 1000;
    _livescoreConnection.serverTimeoutInMilliseconds = 180 * 1000;

    _livescoreConnection.on(
      'UpdateFixtureLivescore',
      (args) => _messageChannel.add(
        Tuple2(enums.MessageType.FixtureLivescoreUpdate, args),
      ),
    );
    _livescoreConnection.on(
      'UpdateFixtureDiscussion',
      (args) => _messageChannel.add(
        Tuple2(enums.MessageType.FixtureDiscussionUpdate, args),
      ),
    );

    await _livescoreConnection.start();

    // var subscriptions = _subscriptionTracker.subscriptions;
    // if (subscriptions.isNotEmpty) {
    //   await _livescoreConnection.invoke(
    //     'AddToGroups',
    //     args: [
    //       AddToGroupsRequestDto(groups: subscriptions),
    //     ],
    //   );
    // }
  }

  Future ensureLivescoreConnected() async {
    if (_livescoreConnected == null) {
      _livescoreConnected = Completer();
      try {
        await _connectToLivescore();
        _livescoreConnected.complete(null);

        return;
      } catch (_) {
        var error = ConnectionError();
        _livescoreConnected.completeError(error);
        _livescoreConnected = null;

        throw error;
      }
    }

    await _livescoreConnected.future;
  }

  Future _connectToFeed() async {
    _feedConnection = HubConnectionBuilder()
        .withUrl(
          '${FlutterConfig.get('FEED_API_BASE_URL')}/feed/hub',
          HttpConnectionOptions(
            transport: HttpTransportType.webSockets,
            skipNegotiation: true,
            accessTokenFactory:
                _accessToken != null ? () => Future.value(_accessToken) : null,
            logging: (level, message) =>
                print('[feed] [$level] $message'), // @@TODO: Proper logging.
          ),
        )
        .build();

    _feedConnection.keepAliveIntervalInMilliseconds = 90 * 1000;
    _feedConnection.serverTimeoutInMilliseconds = 180 * 1000;

    await _feedConnection.start();
  }

  Future ensureFeedConnected() async {
    if (_feedConnected == null) {
      _feedConnected = Completer();
      try {
        await _connectToFeed();
        _feedConnected.complete(null);

        return;
      } catch (_) {
        var error = ConnectionError();
        _feedConnected.completeError(error);
        _feedConnected = null;

        throw error;
      }
    }

    await _feedConnected.future;
  }

  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Future setTokensAndRestartConnections(
    String accessToken,
    String refreshToken,
  ) async {
    setTokens(accessToken, refreshToken);

    if (_livescoreConnection != null) {
      try {
        await _livescoreConnection.stop();
      } catch (error) {
        print(error); // @@TODO: Log properly.
      }

      _livescoreConnection = null;
      _livescoreConnected = null;

      await ensureLivescoreConnected();
    }

    if (_feedConnection != null) {
      try {
        await _feedConnection.stop();
      } catch (error) {
        print(error); // @@TODO: Log properly.
      }

      _feedConnection = null;
      _feedConnected = null;

      await ensureFeedConnected();
    }
  }
}
