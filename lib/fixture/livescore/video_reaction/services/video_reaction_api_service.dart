import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:signalr_core/signalr_core.dart';

import '../models/dto/voted_for_video_reaction_dto.dart';
import '../models/dto/posted_video_reaction_dto.dart';
import '../enums/video_reaction_filter.dart';
import '../enums/video_reaction_vote_action.dart';
import '../errors/video_reaction_error.dart';
import '../interfaces/ivideo_reaction_api_service.dart';
import '../models/dto/fixture_video_reactions_dto.dart';
import '../models/dto/requests/get_video_reactions_for_fixture_request_dto.dart';
import '../models/dto/requests/vote_for_video_reaction_request_dto.dart';
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

  HubConnection get _connection => _serverConnector.connection;
  Dio get _dio => _serverConnector.dio;

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
    }

    print(ex);

    return ApiError();
  }

  dynamic _wrapError(DioError error) {
    // ignore: missing_enum_constant_in_switch
    switch (error.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return ConnectionError();
      case DioErrorType.response:
        var statusCode = error.response.statusCode;
        if (statusCode >= 500) {
          return ServerError();
        }

        switch (statusCode) {
          case 400:
            var failure = error.response.data['failure'];
            if (failure['type'] == 'Validation') {
              return ValidationError();
            } else if (failure['type'] == 'VideoReaction') {
              return VideoReactionError(
                failure['errors'].values.first.first,
              );
            }
            break; // @@NOTE: Should never actually reach here.
          case 401:
            var failureMessage =
                error.response.data['failure']['errors'].values.first.first;
            if (failureMessage.contains('token expired at')) {
              return AuthenticationTokenExpiredError();
            }
            return InvalidAuthenticationTokenError(failureMessage);
          case 403:
            return ForbiddenError();
        }
    }

    print(error);

    return ApiError();
  }

  @override
  Future<FixtureVideoReactionsDto> getVideoReactionsForFixture(
    int fixtureId,
    int teamId,
    VideoReactionFilter filter,
    int start,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      var result = await _connection.invoke(
        'GetVideoReactionsForFixture',
        args: [
          GetVideoReactionsForFixtureRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            filter: filter,
            start: start,
          ),
        ],
      );

      return FixtureVideoReactionsDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<VotedForVideoReactionDto> voteForVideoReaction(
    int fixtureId,
    int teamId,
    int authorId,
    VideoReactionVoteAction voteAction,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      var result = await _connection.invoke(
        'VoteForVideoReaction',
        args: [
          VoteForVideoReactionRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            authorId: authorId,
            voteAction: voteAction,
          ),
        ],
      );

      return VotedForVideoReactionDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<PostedVideoReactionDto> postVideoReaction(
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
        '/api/fixtures/$fixtureId/teams/$teamId/video-reactions',
        options: Options(
          headers: {'Authorization': 'Bearer ${_serverConnector.accessToken}'},
        ),
        data: formData,
      );

      return PostedVideoReactionDto.fromMap(response.data['data']);
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }
}
