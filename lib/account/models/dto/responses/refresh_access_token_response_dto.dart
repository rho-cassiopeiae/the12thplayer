class RefreshAccessTokenResponseDto {
  final String accessToken;
  final String refreshToken;

  RefreshAccessTokenResponseDto.fromJson(Map<String, dynamic> map)
      : accessToken = map['accessToken'],
        refreshToken = map['refreshToken'];
}
