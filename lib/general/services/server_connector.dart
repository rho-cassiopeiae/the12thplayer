import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:tuple/tuple.dart';

import 'subscription_tracker.dart';
import '../enums/message_type.dart' as enums;
import '../models/dto/requests/add_to_groups_request_dto.dart';

class ServerConnector {
  final SubscriptionTracker _subscriptionTracker;

  HubConnection _connection;
  Dio _dio;

  Completer _connected;

  String _accessToken;
  String _refreshToken;

  HubConnection get connection => _connection;
  Dio get dio => _dio;

  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;

  // ignore: close_sinks
  final StreamController<Tuple2<enums.MessageType, List<dynamic>>>
      _messageChannel =
      StreamController<Tuple2<enums.MessageType, List<dynamic>>>.broadcast();

  Stream<Tuple2<enums.MessageType, List<dynamic>>> get message$ =>
      _messageChannel.stream;

  ServerConnector(this._subscriptionTracker) {
    _dio = Dio(
      BaseOptions(
        baseUrl: FlutterConfig.get('WEBSERVER_API_HOST'),
      ),
    );
  }

  Future _connect() async {
    _connection = HubConnectionBuilder()
        .withUrl(
          '${FlutterConfig.get('WEBSERVER_API_HOST')}/fanzone',
          HttpConnectionOptions(
            transport: HttpTransportType.webSockets,
            skipNegotiation: true,
            accessTokenFactory:
                _accessToken != null ? () => Future.value(_accessToken) : null,
            logging: (level, message) => print('[$level] $message'),
          ),
        )
        .build();

    _connection.keepAliveIntervalInMilliseconds = 90 * 1000;
    _connection.serverTimeoutInMilliseconds = 180 * 1000;

    _connection.on(
      'UpdateFixtureLivescore',
      (args) => _messageChannel.add(
        Tuple2(enums.MessageType.LivescoreUpdate, args),
      ),
    );
    _connection.on(
      'UpdateLiveCommentaryFeed',
      (args) => _messageChannel.add(
        Tuple2(enums.MessageType.LiveCommentaryFeedUpdate, args),
      ),
    );
    _connection.on(
      'UpdateDiscussion',
      (args) => _messageChannel.add(
        Tuple2(enums.MessageType.DiscussionUpdate, args),
      ),
    );

    await _connection.start();

    var subscriptions = _subscriptionTracker.subscriptions;
    if (subscriptions.isNotEmpty) {
      await _connection.invoke(
        'AddToGroups',
        args: [
          AddToGroupsRequestDto(groups: subscriptions),
        ],
      );
    }
  }

  Future ensureConnected() async {
    if (_connected == null) {
      _connected = Completer();
      try {
        await _connect();
        _connected.complete(null);

        return;
      } catch (error) {
        _connected.completeError(error);
        _connected = null;

        rethrow;
      }
    }

    await _connected.future;
  }

  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Future setTokensAndAbortConnection(
    String accessToken,
    String refreshToken,
  ) async {
    setTokens(accessToken, refreshToken);
    if (_connection != null) {
      await _connection.stop();
      _connection = null;
      _connected = null;
    }
  }
}
