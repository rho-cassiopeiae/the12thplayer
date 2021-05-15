class ConfirmEmailResponseDto {
  final String accessToken;
  final String refreshToken;

  ConfirmEmailResponseDto.fromJson(Map<String, dynamic> map)
      : accessToken = map['accessToken'],
        refreshToken = map['refreshToken'];
}
