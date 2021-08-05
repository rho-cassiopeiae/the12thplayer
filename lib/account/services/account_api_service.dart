import 'package:dio/dio.dart';

import '../../general/services/server_connector.dart';
import '../errors/account_error.dart';
import '../../general/errors/api_error.dart';
import '../../general/errors/authentication_token_expired_error.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/forbidden_error.dart';
import '../../general/errors/invalid_authentication_token_error.dart';
import '../../general/errors/server_error.dart';
import '../../general/errors/validation_error.dart';
import '../interfaces/iaccount_api_service.dart';
import '../models/dto/requests/confirm_email_request_dto.dart';
import '../models/dto/requests/refresh_access_token_request_dto.dart';
import '../models/dto/requests/sign_in_request_dto.dart';
import '../models/dto/requests/sign_up_request_dto.dart';
import '../models/dto/responses/confirm_email_response_dto.dart';
import '../models/dto/responses/refresh_access_token_response_dto.dart';
import '../models/dto/responses/sign_in_response_dto.dart';

class AccountApiService implements IAccountApiService {
  final ServerConnector _serverConnector;

  AccountApiService(this._serverConnector);

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
            } else if (failure['type'] == 'Account') {
              return AccountError(failure['errors'].values.first.first);
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
  Future signUp(String email, String username, String password) async {
    try {
      await _serverConnector.dioIdentity.post(
        '/api/account/sign-up',
        data: SignUpRequestDto(
          email: email,
          username: username,
          password: password,
        ).toJson(),
      );
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future<ConfirmEmailResponseDto> confirmEmail(
    String email,
    String confirmationCode,
  ) async {
    try {
      var response = await _serverConnector.dioIdentity.post(
        '/api/account/confirm-email',
        data: ConfirmEmailRequestDto(
          email: email,
          confirmationCode: confirmationCode,
        ).toJson(),
      );

      return ConfirmEmailResponseDto.fromJson(response.data['data']);
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future<SignInResponseDto> signIn(String email, String password) async {
    try {
      var response = await _serverConnector.dioIdentity.post(
        '/api/account/sign-in',
        data: SignInRequestDto(
          email: email,
          password: password,
        ).toJson(),
      );

      return SignInResponseDto.fromJson(response.data['data']);
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future<RefreshAccessTokenResponseDto> refreshAccessToken() async {
    try {
      var response = await _serverConnector.dioIdentity.post(
        '/api/account/refresh-access-token',
        data: RefreshAccessTokenRequestDto(
          accessToken: _serverConnector.accessToken,
          refreshToken: _serverConnector.refreshToken,
        ).toJson(),
      );

      return RefreshAccessTokenResponseDto.fromJson(response.data['data']);
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future createProfile(String accessToken, String email) async {
    var formData = FormData.fromMap(
      {
        'email': email,
      },
    );

    try {
      await _serverConnector.dio.put(
        '/api/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: formData,
      );
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future updateProfileImage(List<int> imageBytes, String filename) async {
    var formData = FormData.fromMap(
      {
        'image': MultipartFile.fromBytes(imageBytes, filename: filename),
      },
    );

    try {
      await _serverConnector.dio.post(
        '/api/profile/update-profile-image',
        options: Options(
          headers: {'Authorization': 'Bearer ${_serverConnector.accessToken}'},
        ),
        data: formData,
      );
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }
}
