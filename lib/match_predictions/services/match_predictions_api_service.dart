import 'package:dio/dio.dart';

import '../models/dto/match_predictions_submission_dto.dart';
import '../../general/errors/authentication_token_expired_error.dart';
import '../../general/errors/forbidden_error.dart';
import '../../general/errors/invalid_authentication_token_error.dart';
import '../../general/errors/api_error.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../../general/errors/validation_error.dart';
import '../../general/services/server_connector.dart';
import '../interfaces/imatch_predictions_api_service.dart';
import '../models/dto/active_season_round_with_fixtures_dto.dart';

class MatchPredictionsApiService implements IMatchPredictionsApiService {
  final ServerConnector _serverConnector;

  Dio get _dio => _serverConnector.dioMatchPredictions;

  MatchPredictionsApiService(this._serverConnector);

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
        }

        switch (statusCode) {
          case 400:
            var error = dioError.response.data['error'];
            if (error['type'] == 'Validation') {
              return ValidationError();
            }
            break; // @@NOTE: Should never actually reach here.
          case 401:
            var errorMessage =
                dioError.response.data['error']['errors'].values.first.first;
            if (errorMessage.contains('token expired at')) {
              return AuthenticationTokenExpiredError();
            }
            return InvalidAuthenticationTokenError(errorMessage);
          case 403:
            return ForbiddenError();
        }
    }

    print(dioError);

    return ApiError();
  }

  @override
  Future<Iterable<ActiveSeasonRoundWithFixturesDto>> getActiveFixturesForTeam(
    int teamId,
  ) async {
    try {
      var response = await _dio.get(
        '/match-predictions/teams/$teamId',
        options: _serverConnector.accessToken != null
            ? Options(
                headers: {
                  'Authorization': 'Bearer ${_serverConnector.accessToken}'
                },
              )
            : null,
      );

      return (response.data['data'] as List).map(
        (seasonRoundMap) =>
            ActiveSeasonRoundWithFixturesDto.fromMap(seasonRoundMap),
      );
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future<MatchPredictionsSubmissionDto> submitMatchPredictions(
    int seasonId,
    int roundId,
    Map<int, String> fixtureIdToScore,
  ) async {
    try {
      var response = await _dio.post(
        '/match-predictions/seasons/$seasonId/rounds/$roundId',
        data: fixtureIdToScore.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
        options: Options(
          headers: {'Authorization': 'Bearer ${_serverConnector.accessToken}'},
        ),
      );

      return MatchPredictionsSubmissionDto.fromMap(response.data['data']);
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }
}
