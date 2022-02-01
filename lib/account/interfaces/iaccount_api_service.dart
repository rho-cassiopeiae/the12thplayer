import '../models/dto/responses/refresh_access_token_response_dto.dart';
import '../models/dto/responses/sign_in_response_dto.dart';

abstract class IAccountApiService {
  Future signUp(String email, String username, String password);

  Future confirmEmail(String email, String confirmationCode);

  Future<SignInResponseDto> signIn(
    String deviceId,
    String email,
    String password,
  );

  Future<RefreshAccessTokenResponseDto> refreshAccessToken(
    String deviceId,
    String accessToken,
    String refreshToken,
  );

  Future updateProfileImage(List<int> imageBytes, String filename);
}
