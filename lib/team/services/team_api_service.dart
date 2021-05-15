import 'package:dio/dio.dart';

import '../../general/errors/api_error.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../../general/errors/validation_error.dart';
import '../../general/services/server_connector.dart';
import '../interfaces/iteam_api_service.dart';
import '../models/dto/fixture_performance_rating_dto.dart';
import '../models/dto/team_squad_dto.dart';

class TeamApiService implements ITeamApiService {
  final ServerConnector _serverConnector;

  Dio get _dio => _serverConnector.dio;

  TeamApiService(this._serverConnector);

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
            }
            break; // @@NOTE: Should never actually reach here.
        }
    }

    print(error);

    return ApiError();
  }

  @override
  Future<TeamSquadDto> getTeamSquad(int teamId) async {
    try {
      var response = await _dio.get('/api/teams/$teamId/squad');

      return TeamSquadDto.fromMap(response.data['data']);
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future<Iterable<FixturePerformanceRatingDto>> getTeamPlayerPerformanceRatings(
    int teamId,
    int playerId,
  ) async {
    try {
      var response = await _dio.get(
        '/api/teams/$teamId/squad/players/$playerId/performance-ratings',
      );

      return (response.data['data'] as List<dynamic>)
          .map((ratingMap) => FixturePerformanceRatingDto.fromMap(ratingMap));
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future<Iterable<FixturePerformanceRatingDto>>
      getTeamManagerPerformanceRatings(
    int teamId,
    int managerId,
  ) async {
    try {
      var response = await _dio.get(
        '/api/teams/$teamId/squad/managers/$managerId/performance-ratings',
      );

      return (response.data['data'] as List<dynamic>)
          .map((ratingMap) => FixturePerformanceRatingDto.fromMap(ratingMap));
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }
}
