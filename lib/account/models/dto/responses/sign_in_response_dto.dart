import 'confirm_email_response_dto.dart';

class SignInResponseDto extends ConfirmEmailResponseDto {
  final String username;

  SignInResponseDto.fromJson(Map<String, dynamic> map)
      : username = map['username'],
        super.fromJson(map);
}
