import 'dart:async';
import 'dart:convert';

import 'package:brotli/brotli.dart';
import 'package:dio/dio.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../../general/services/subscription_tracker.dart';
import '../../../general/enums/message_type.dart' as enums;
import '../errors/fixture_error.dart';
import '../models/dto/performance_rating_dto.dart';
import '../../livescore/models/dto/requests/rate_participant_of_given_fixture_request_dto.dart';
import '../../../general/errors/authentication_token_expired_error.dart';
import '../../../general/errors/forbidden_error.dart';
import '../../../general/errors/invalid_authentication_token_error.dart';
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

  Dio get _dio => _serverConnector.dio;
  HubConnection get _connection => _serverConnector.connection;

  final Map<String, StreamController<FixtureLivescoreUpdateDto>>
      _fixtureIdentifierToUpdatesChannel = {};

  FixtureApiService(
    this._serverConnector,
    this._subscriptionTracker,
  ) {
    _serverConnector.message$
        .where((message) => message.item1 == enums.MessageType.LivescoreUpdate)
        .listen((message) {
      _updateFixtureLivescore(message.item2);
    });
  }

  dynamic _wrapError(DioError error) {
    // ignore: missing_enum_constant_in_switch
    switch (error.type) {
      case DioErrorType.CONNECT_TIMEOUT:
      case DioErrorType.SEND_TIMEOUT:
      case DioErrorType.RECEIVE_TIMEOUT:
        return ConnectionError();
      case DioErrorType.RESPONSE:
        var statusCode = error.response.statusCode;
        if (statusCode >= 500) {
          return ServerError();
        }

        switch (statusCode) {
          case 400:
            var failure = error.response.data['failure'];
            if (failure['type'] == 'Validation') {
              return ValidationError();
            } else if (failure['type'] == 'Fixture') {
              return FixtureError(failure['errors'].values.first.first);
            }
            break; // @@NOTE: Should never actually reach here.
        }
    }

    print(error);

    return ApiError();
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
    } else if (errorMessage.contains('[FixtureError]')) {
      return FixtureError(errorMessage.split('[FixtureError] ').last);
    }

    print(ex);

    return ApiError();
  }

  @override
  Future<Iterable<FixtureSummaryDto>> getFixturesForTeamInBetween(
    int teamId,
    int startTime,
    int endTime,
  ) async {
    try {
      var response = await _dio.get(
        '/api/fixtures',
        queryParameters: {
          'teamId': teamId,
          'startTime': startTime,
          'endTime': endTime,
        },
      );

      return (response.data['data'] as List<dynamic>).map(
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
        '/api/fixtures/$fixtureId',
        queryParameters: {
          'teamId': teamId,
        },
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

    var fixtureIdentifier = 'fixture:${update.fixtureId}.team:${update.teamId}';
    if (_fixtureIdentifierToUpdatesChannel.containsKey(fixtureIdentifier)) {
      _fixtureIdentifierToUpdatesChannel[fixtureIdentifier].add(update);
    }
  }

  @override
  Future<Stream<FixtureLivescoreUpdateDto>> subscribeToFixture(
    int fixtureId,
    int teamId,
  ) async {
    await _serverConnector.ensureConnected();

    var fixtureIdentifier = 'fixture:$fixtureId.team:$teamId';
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
  void unsubscribeFromFixture(int fixtureId, int teamId) async {
    await _serverConnector.ensureConnected();

    var fixtureIdentifier = 'fixture:$fixtureId.team:$teamId';
    _subscriptionTracker.removeSubscription(fixtureIdentifier);

    var updatesChannel = _fixtureIdentifierToUpdatesChannel.remove(
      fixtureIdentifier,
    );
    if (updatesChannel != null) {
      updatesChannel.close();

      await _connection.invoke(
        'UnsubscribeFromFixture',
        args: [
          UnsubscribeFromFixtureRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
          ),
        ],
      );
    }
  }

  @override
  Future<PerformanceRatingDto> rateParticipantOfGivenFixture(
    int fixtureId,
    int teamId,
    String participantIdentifier,
    int rating,
    int oldRating,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      var result = await _connection.invoke(
        'RateParticipantOfGivenFixture',
        args: [
          RateParticipantOfGivenFixtureRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            participantIdentifier: participantIdentifier,
            rating: rating,
            oldRating: oldRating,
          ),
        ],
      );

      return PerformanceRatingDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }
}
