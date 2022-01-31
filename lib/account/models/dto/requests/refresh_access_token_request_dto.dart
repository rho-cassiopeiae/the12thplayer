import 'package:flutter/foundation.dart';

class RefreshAccessTokenRequestDto {
  final String deviceId;
  final String accessToken;
  final String refreshToken;

  RefreshAccessTokenRequestDto({
    @required this.deviceId,
    @required this.accessToken,
    @required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['deviceId'] = deviceId;
    map['accessToken'] = accessToken;
    map['refreshToken'] = refreshToken;

    return map;
  }
}
