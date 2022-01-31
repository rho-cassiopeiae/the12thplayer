import 'package:dio/dio.dart';

import '../../general/errors/api_error.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../../general/errors/validation_error.dart';
import '../../general/services/server_connector.dart';
import '../interfaces/iteam_api_service.dart';
import '../models/dto/fixture_player_rating_dto.dart';
import '../models/dto/team_squad_dto.dart';

class TeamApiService implements ITeamApiService {
  final ServerConnector _serverConnector;

  Dio get _dio => _serverConnector.dioLivescore;

  TeamApiService(this._serverConnector);

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
        }
    }

    print(dioError);

    return ApiError();
  }

  // @override
  // Future<Iterable<TeamDto>> getTeamsWithCommunities() async {
  //   try {
  //     var response = await _dio.get('/api/teams');

  //     return (response.data['data'] as List<dynamic>)
  //         .map((teamMap) => TeamDto.fromMap(teamMap));
  //   } on DioError catch (error) {
  //     throw _wrapError(error);
  //   }
  // }

  @override
  Future<TeamSquadDto> getTeamSquad(int teamId) async {
    try {
      var response = await _dio.get('/livescore/teams/$teamId/squad');
      return TeamSquadDto.fromMap(response.data['data']);
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future<Iterable<FixturePlayerRatingDto>> getTeamPlayerRatings(
    int teamId,
    int playerId,
  ) async {
    try {
      var response = await _dio.get(
        '/livescore/teams/$teamId/players/$playerId/ratings',
      );

      return (response.data['data'] as List)
          .map((ratingMap) => FixturePlayerRatingDto.fromMap(ratingMap));
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future<Iterable<FixturePlayerRatingDto>> getTeamManagerRatings(
    int teamId,
    int managerId,
  ) async {
    try {
      var response = await _dio.get(
        '/livescore/teams/$teamId/managers/$managerId/ratings',
      );

      return (response.data['data'] as List)
          .map((ratingMap) => FixturePlayerRatingDto.fromMap(ratingMap));
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }
}
