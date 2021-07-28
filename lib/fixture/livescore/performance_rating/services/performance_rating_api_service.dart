import 'package:signalr_core/signalr_core.dart';

import '../models/dto/performance_rating_dto.dart';
import '../models/dto/requests/rate_participant_of_given_fixture_request_dto.dart';
import '../errors/performance_rating_error.dart';
import '../interfaces/iperformance_rating_api_service.dart';
import '../models/dto/fixture_performance_ratings_dto.dart';
import '../models/dto/requests/get_performance_ratings_for_fixture_request_dto.dart';
import '../../../../general/errors/api_error.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/errors/forbidden_error.dart';
import '../../../../general/errors/invalid_authentication_token_error.dart';
import '../../../../general/errors/validation_error.dart';
import '../../../../general/services/server_connector.dart';

class PerformanceRatingApiService implements IPerformanceRatingApiService {
  final ServerConnector _serverConnector;

  HubConnection get _connection => _serverConnector.connection;

  PerformanceRatingApiService(this._serverConnector);

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
    } else if (errorMessage.contains('[PerformanceRatingError]')) {
      return PerformanceRatingError(
        errorMessage.split('[PerformanceRatingError] ').last,
      );
    }

    print(ex);

    return ApiError();
  }

  @override
  Future<FixturePerformanceRatingsDto> getPerformanceRatingsForFixture(
    int fixtureId,
    int teamId,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      var result = await _connection.invoke(
        'GetPerformanceRatingsForFixture',
        args: [
          GetPerformanceRatingsForFixtureRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
          ),
        ],
      );

      return FixturePerformanceRatingsDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<PerformanceRatingDto> rateParticipantOfGivenFixture(
    int fixtureId,
    int teamId,
    String participantIdentifier,
    double rating,
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
          ),
        ],
      );

      return PerformanceRatingDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }
}
