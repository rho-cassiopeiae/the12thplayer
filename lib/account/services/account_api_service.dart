import 'package:dio/dio.dart';

import '../../general/services/server_connector.dart';
import '../errors/account_error.dart';
import '../../general/errors/api_error.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../../general/errors/validation_error.dart';
import '../interfaces/iaccount_api_service.dart';
import '../models/dto/requests/confirm_email_request_dto.dart';
import '../models/dto/requests/refresh_access_token_request_dto.dart';
import '../models/dto/requests/sign_in_request_dto.dart';
import '../models/dto/requests/sign_up_request_dto.dart';
import '../models/dto/responses/refresh_access_token_response_dto.dart';
import '../models/dto/responses/sign_in_response_dto.dart';

class AccountApiService implements IAccountApiService {
  final ServerConnector _serverConnector;

  Dio get _dio => _serverConnector.dioIdentity;

  AccountApiService(this._serverConnector);

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
          } else if (error['type'] == 'Account') {
            return AccountError(error['errors'].values.first.first);
          }
          // @@NOTE: Should never actually reach here.
        }
    }

    print(dioError);

    return ApiError();
  }

  @override
  Future signUp(String email, String username, String password) async {
    try {
      await _dio.post(
        '/identity/account/sign-up',
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
  Future confirmEmail(String email, String confirmationCode) async {
    try {
      await _dio.post(
        '/identity/account/confirm-email',
        data: ConfirmEmailRequestDto(
          email: email,
          confirmationCode: confirmationCode,
        ).toJson(),
      );
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future<SignInResponseDto> signIn(
    String deviceId,
    String email,
    String password,
  ) async {
    try {
      var response = await _dio.post(
        '/identity/account/sign-in',
        data: SignInRequestDto(
          deviceId: deviceId,
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
  Future<RefreshAccessTokenResponseDto> refreshAccessToken(
    String deviceId,
    String accessToken,
    String refreshToken,
  ) async {
    try {
      var response = await _dio.post(
        '/identity/account/refresh-access-token',
        data: RefreshAccessTokenRequestDto(
          deviceId: deviceId,
          accessToken: accessToken,
          refreshToken: refreshToken,
        ).toJson(),
      );

      return RefreshAccessTokenResponseDto.fromJson(response.data['data']);
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  // @override
  // Future updateProfileImage(List<int> imageBytes, String filename) async {
  //   var formData = FormData.fromMap(
  //     {
  //       'image': MultipartFile.fromBytes(imageBytes, filename: filename),
  //     },
  //   );

  //   try {
  //     await _serverConnector.dioProfile.post(
  //       '/api/profile/update-profile-image',
  //       options: Options(
  //         headers: {'Authorization': 'Bearer ${_serverConnector.accessToken}'},
  //       ),
  //       data: formData,
  //     );
  //   } on DioError catch (error) {
  //     throw _wrapError(error);
  //   }
  // }
}
