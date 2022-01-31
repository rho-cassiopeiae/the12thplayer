import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../errors/livescore_error.dart';
import '../models/dto/video_reaction_rating_dto.dart';
import '../enums/video_reaction_filter.dart';
import '../errors/video_reaction_error.dart';
import '../interfaces/ivideo_reaction_api_service.dart';
import '../models/dto/fixture_video_reactions_dto.dart';
import '../models/dto/requests/get_video_reactions_for_fixture_request_dto.dart';
import '../models/dto/requests/vote_for_video_reaction_request_dto.dart';
import '../../../../general/errors/file_error.dart';
import '../../../../general/errors/api_error.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/errors/connection_error.dart';
import '../../../../general/errors/forbidden_error.dart';
import '../../../../general/errors/invalid_authentication_token_error.dart';
import '../../../../general/errors/server_error.dart';
import '../../../../general/errors/validation_error.dart';
import '../../../../general/services/server_connector.dart';

class VideoReactionApiService implements IVideoReactionApiService {
  final ServerConnector _serverConnector;

  HubConnection get _connection => _serverConnector.livescoreConnection;
  Dio get _dio => _serverConnector.dioLivescore;

  VideoReactionApiService(this._serverConnector);

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
    } else if (errorMessage.contains('[VideoReactionError]')) {
      return VideoReactionError(
        errorMessage.split('[VideoReactionError] ').last,
      );
    } else if (errorMessage.contains('[LivescoreError]')) {
      return LivescoreError(errorMessage.split('[LivescoreError] ').last);
    }

    print(ex);

    return ServerError();
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
        }

        switch (statusCode) {
          case 400:
            var error = dioError.response.data['error'];
            if (error['type'] == 'Validation') {
              return ValidationError();
            } else if (error['type'] == 'File') {
              return FileError(
                error['errors'].values.first.first,
              );
            } else if (error['type'] == 'VideoReaction') {
              return VideoReactionError(
                error['errors'].values.first.first,
              );
            } else if (error['type'] == 'Livescore') {
              return LivescoreError(
                error['errors'].values.first.first,
              );
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
  Future<FixtureVideoReactionsDto> getVideoReactionsForFixture(
    int fixtureId,
    int teamId,
    VideoReactionFilter filter,
    int page,
  ) async {
    await _serverConnector.ensureLivescoreConnected();

    try {
      var result = await _connection.invoke(
        'GetVideoReactionsForFixture',
        args: [
          GetVideoReactionsForFixtureRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            filter: filter,
            page: page,
          ),
        ],
      );

      return FixtureVideoReactionsDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<VideoReactionRatingDto> voteForVideoReaction(
    int fixtureId,
    int teamId,
    int authorId,
    int userVote,
  ) async {
    await _serverConnector.ensureLivescoreConnected();

    try {
      var result = await _connection.invoke(
        'VoteForVideoReaction',
        args: [
          VoteForVideoReactionRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            authorId: authorId,
            userVote: userVote,
          ),
        ],
      );

      return VideoReactionRatingDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<String> postVideoReaction(
    int fixtureId,
    int teamId,
    String title,
    Uint8List videoBytes,
    String fileName,
  ) async {
    var formData = FormData.fromMap(
      {
        'title': title,
        'video': MultipartFile.fromBytes(videoBytes, filename: fileName),
      },
    );

    try {
      var response = await _dio.post(
        '/livescore/teams/$teamId/fixtures/$fixtureId/video-reactions',
        options: Options(
          headers: {'Authorization': 'Bearer ${_serverConnector.accessToken}'},
        ),
        data: formData,
      );

      return response.data['data'];
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }
}
