import 'package:dio/dio.dart';
import 'package:signalr_core/signalr_core.dart';

import '../models/dto/live_commentary_recording_entry_dto.dart';
import '../models/dto/requests/post_live_commentary_recording_entries_request_dto.dart';
import '../models/dto/requests/post_live_commentary_recording_entry_request_dto.dart';
import '../../../../general/errors/connection_error.dart';
import '../../../../general/errors/server_error.dart';
import '../errors/live_commentary_recording_error.dart';
import '../interfaces/ilive_commentary_recording_api_service.dart';
import '../models/dto/requests/create_live_commentary_recording_request_dto.dart';
import '../../../../general/errors/api_error.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/errors/forbidden_error.dart';
import '../../../../general/errors/invalid_authentication_token_error.dart';
import '../../../../general/errors/validation_error.dart';
import '../../../../general/services/server_connector.dart';

class LiveCommentaryRecordingApiService
    implements ILiveCommentaryRecordingApiService {
  final ServerConnector _serverConnector;

  HubConnection get _connection => _serverConnector.connection;
  Dio get _dio => _serverConnector.dio;

  LiveCommentaryRecordingApiService(this._serverConnector);

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
    } else if (errorMessage.contains('[LiveCommentaryError]')) {
      return LiveCommentaryRecordingError(
        errorMessage.split('[LiveCommentaryError] ').last,
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
            } else if (failure['type'] == 'LiveCommentary') {
              return LiveCommentaryRecordingError(
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
  Future createLiveCommentaryRecording(
    int fixtureId,
    int teamId,
    String name,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      await _connection.invoke(
        'CreateLiveCommentaryRecording',
        args: [
          CreateLiveCommentaryRecordingRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            name: name,
          ),
        ],
      );
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future postLiveCommentaryRecordingEntry(
    int fixtureId,
    int teamId,
    LiveCommentaryRecordingEntryDto entry,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      await _connection.invoke(
        'PostLiveCommentaryRecordingEntry',
        args: [
          PostLiveCommentaryRecordingEntryRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            entry: entry,
          ),
        ],
      );
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future postLiveCommentaryRecordingEntries(
    int fixtureId,
    int teamId,
    Iterable<LiveCommentaryRecordingEntryDto> entries,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      await _connection.invoke(
        'PostLiveCommentaryRecordingEntries',
        args: [
          PostLiveCommentaryRecordingEntriesRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            entries: entries,
          ),
        ],
      );
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<String> uploadLiveCommentaryRecordingEntryImage(
    int fixtureId,
    int teamId,
    String imagePath,
  ) async {
    var formData = FormData.fromMap(
      {
        'image': await MultipartFile.fromFile(imagePath),
      },
    );

    try {
      var response = await _dio.post(
        '/api/fixtures/$fixtureId/teams/$teamId/live-commentaries/upload-image',
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
