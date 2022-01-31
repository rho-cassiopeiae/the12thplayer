import 'package:signalr_core/signalr_core.dart';

import '../../errors/livescore_error.dart';
import '../models/dto/player_rating_dto.dart';
import '../models/dto/requests/rate_player_request_dto.dart';
import '../interfaces/iplayer_rating_api_service.dart';
import '../models/dto/fixture_player_ratings_dto.dart';
import '../models/dto/requests/get_player_ratings_for_fixture_request_dto.dart';
import '../../../../general/errors/server_error.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/errors/forbidden_error.dart';
import '../../../../general/errors/invalid_authentication_token_error.dart';
import '../../../../general/errors/validation_error.dart';
import '../../../../general/services/server_connector.dart';

class PlayerRatingApiService implements IPlayerRatingApiService {
  final ServerConnector _serverConnector;

  HubConnection get _connection => _serverConnector.livescoreConnection;

  PlayerRatingApiService(this._serverConnector);

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
    } else if (errorMessage.contains('[LivescoreError]')) {
      return LivescoreError(errorMessage.split('[LivescoreError] ').last);
    }

    print(ex);

    return ServerError();
  }

  @override
  Future<FixturePlayerRatingsDto> getPlayerRatingsForFixture(
    int fixtureId,
    int teamId,
  ) async {
    await _serverConnector.ensureLivescoreConnected();

    try {
      var result = await _connection.invoke(
        'GetPlayerRatingsForFixture',
        args: [
          GetPlayerRatingsForFixtureRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
          ),
        ],
      );

      return FixturePlayerRatingsDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<PlayerRatingDto> ratePlayer(
    int fixtureId,
    int teamId,
    String participantKey,
    double rating,
  ) async {
    await _serverConnector.ensureLivescoreConnected();

    try {
      var result = await _connection.invoke(
        'RatePlayer',
        args: [
          RatePlayerRequestDto(
            fixtureId: fixtureId,
            teamId: teamId,
            participantKey: participantKey,
            rating: rating,
          ),
        ],
      );

      return PlayerRatingDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }
}
