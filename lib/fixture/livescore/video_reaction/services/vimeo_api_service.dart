import 'package:dio/dio.dart';

import '../interfaces/ivimeo_api_service.dart';
import '../../../../general/errors/api_error.dart';
import '../../../../general/errors/connection_error.dart';
import '../../../../general/errors/server_error.dart';

class VimeoApiService implements IVimeoApiService {
  Dio _dio;

  VimeoApiService() {
    _dio = Dio(
      BaseOptions(baseUrl: 'https://player.vimeo.com/video'),
    );
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
    }

    print(error);

    return ApiError();
  }

  Future<Map<String, String>> getVideoQualityUrls(String videoId) async {
    try {
      var response = await _dio.get('/$videoId/config');

      var qualityToUrl = Map.fromIterable(
        response.data['request']['files']['progressive'],
        key: (item) => item['height'].toString(),
        value: (item) => item['url'] as String,
      );
      qualityToUrl.remove('240');

      return qualityToUrl;
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }
}
