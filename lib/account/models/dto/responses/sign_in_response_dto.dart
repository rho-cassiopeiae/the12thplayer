class SignInResponseDto {
  final String username;
  final String accessToken;
  final String refreshToken;

  SignInResponseDto.fromJson(Map<String, dynamic> map)
      : username = map['username'],
        accessToken = map['accessToken'],
        refreshToken = map['refreshToken'];
}
