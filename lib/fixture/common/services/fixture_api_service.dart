import 'dart:async';
import 'dart:convert';

import 'package:brotli/brotli.dart';
import 'package:dio/dio.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../../general/services/subscription_tracker.dart';
import '../../../general/enums/message_type.dart' as enums;
import '../../livescore/models/dto/requests/unsubscribe_from_fixture_request_dto.dart';
import '../../livescore/models/dto/fixture_full_dto.dart';
import '../../livescore/models/dto/fixture_livescore_update_dto.dart';
import '../../livescore/models/dto/requests/subscribe_to_fixture_request_dto.dart';
import '../models/dto/fixture_summary_dto.dart';
import '../../../general/errors/api_error.dart';
import '../../../general/errors/connection_error.dart';
import '../../../general/errors/server_error.dart';
import '../../../general/errors/validation_error.dart';
import '../../../general/services/server_connector.dart';
import '../interfaces/ifixture_api_service.dart';

class FixtureApiService implements IFixtureApiService {
  final ServerConnector _serverConnector;
  final SubscriptionTracker _subscriptionTracker;

  Dio get _dio => _serverConnector.dioLivescore;
  HubConnection get _connection => _serverConnector.livescoreConnection;

  final Map<String, StreamController<FixtureLivescoreUpdateDto>>
      _fixtureIdentifierToUpdatesChannel = {};

  FixtureApiService(
    this._serverConnector,
    this._subscriptionTracker,
  ) {
    _serverConnector.message$
        .where((message) =>
            message.item1 == enums.MessageType.FixtureLivescoreUpdate)
        .listen((message) {
      _updateFixtureLivescore(message.item2);
    });
  }

  dynamic _wrapError(DioError dioError) {
    // ignore: missing_enum_constant_in_switch
    switch (dioError.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return ConnectionError();
      case DioErrorType.response:
        var statusCode = dioError.response.statusCode;
        if (statusCode >= 500) {
          return ServerError();
        } else if (statusCode == 400) {
          var error = dioError.response.data['error'];
          if (error['type'] == 'Validation') {
            return ValidationError();
          }
          // @@NOTE: Should never actually reach here.
        }
    }

    print(dioError);

    return ApiError();
  }

  dynamic _wrapHubException(Exception ex) {
    var errorMessage = ex.toString();
    if (errorMessage.contains('[ValidationError]')) {
      return ValidationError();
    }

    print(ex);

    return ServerError();
  }

  @override
  Future<Iterable<FixtureSummaryDto>> getFixturesForTeamInBetween(
    int teamId,
    int startTime,
    int endTime,
  ) async {
    try {
      var response = await _dio.get(
        '/livescore/teams/$teamId/fixtures',
        queryParameters: {
          'startTime': startTime,
          'endTime': endTime,
        },
      );

      return (response.data['data'] as List).map(
        (fixtureMap) => FixtureSummaryDto.fromMap(fixtureMap),
      );
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future<FixtureFullDto> getFixtureForTeam(int fixtureId, int teamId) async {
    try {
      var response = await _dio.get(
        '/livescore/teams/$teamId/fixtures/$fixtureId',
      );

      return FixtureFullDto.fromMap(response.data['data']);
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  void _updateFixtureLivescore(List<dynamic> args) {
    var update = FixtureLivescoreUpdateDto.fromMap(
      jsonDecode(utf8.decode(brotli.decode(base64Decode(args[0])))),
    );

    var fixtureIdentifier = 'f:${update.fixtureId}.t:${update.teamId}';
    if (_fixtureIdentifierToUpdatesChannel.containsKey(fixtureIdentifier)) {
      _fixtureIdentifierToUpdatesChannel[fixtureIdentifier].add(update);
    }
  }

  @override
  Future<Stream<FixtureLivescoreUpdateDto>> subscribeToFixture(
    int fixtureId,
    int teamId,
  ) async {
    await _serverConnector.ensureLivescoreConnected();

    var fixtureIdentifier = 'f:$fixtureId.t:$teamId';
    _subscriptionTracker.addSubscription(fixtureIdentifier);

    try {
      await _connection.invoke(
        'SubscribeToFixture',
        args: [
          SubscribeToFixtureRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
          ),
        ],
      );
    } on Exception catch (ex) {
      _subscriptionTracker.removeSubscription(fixtureIdentifier);
      throw _wrapHubException(ex);
    }

    // ignore: close_sinks
    var updatesChannel = StreamController<FixtureLivescoreUpdateDto>();
    _fixtureIdentifierToUpdatesChannel[fixtureIdentifier] = updatesChannel;

    return updatesChannel.stream;
  }

  @override
  Future unsubscribeFromFixture(int fixtureId, int teamId) async {
    await _serverConnector.ensureLivescoreConnected();

    var fixtureIdentifier = 'f:$fixtureId.t:$teamId';
    _subscriptionTracker.removeSubscription(fixtureIdentifier);

    var updatesChannel = _fixtureIdentifierToUpdatesChannel.remove(
      fixtureIdentifier,
    );
    if (updatesChannel != null) {
      updatesChannel.close();

      try {
        await _connection.invoke(
          'UnsubscribeFromFixture',
          args: [
            UnsubscribeFromFixtureRequestDto(
              fixtureId: fixtureId,
              teamId: teamId,
            ),
          ],
        );
      } on Exception catch (ex) {
        throw _wrapHubException(ex);
      }
    }
  }
}
