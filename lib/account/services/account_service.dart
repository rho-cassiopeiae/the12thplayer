import 'dart:math';

import 'package:either_option/either_option.dart';

import '../../general/services/notification_service.dart';
import '../enums/account_type.dart';
import '../interfaces/iaccount_api_service.dart';
import '../models/entities/account_entity.dart';
import '../models/vm/account_vm.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../../general/persistence/storage.dart';
import '../../general/services/server_connector.dart';
import '../../general/utils/policy.dart';
import '../../general/errors/error.dart';

class AccountService {
  final Storage _storage;
  final ServerConnector _serverConnector;
  final IAccountApiService _accountApiService;
  final NotificationService _notificationService;

  Policy _policy;

  AccountService(
    this._storage,
    this._serverConnector,
    this._accountApiService,
    this._notificationService,
  ) {
    _policy = PolicyBuilder().on<ConnectionError>(
      strategies: [
        When(
          any,
          repeat: 1,
          withInterval: (_) => Duration(milliseconds: 200),
        ),
      ],
    ).on<ServerError>(
      strategies: [
        When(
          any,
          repeat: 3,
          withInterval: (attempt) => Duration(
            milliseconds: 200 * pow(2, attempt),
          ),
        ),
      ],
    ).build();
  }

  Future<Either<Error, AccountVm>> loadAccount() async {
    try {
      var account = await _storage.loadAccount();
      if (account.type == AccountType.User) {
        // @@??: Set tokens only on app startup ?
        _serverConnector.setTokens(account.accessToken, account.refreshToken);
      }

      return Right(AccountVm.fromEntity(account));
    } catch (error) {
      return Left(Error(error.toString()));
    }
  }

  Future<Option<Error>> signUp(
    String email,
    String username,
    String password,
  ) async {
    try {
      await _policy.execute(
        () => _accountApiService.signUp(email, username, password),
      );

      return None();
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return Some(Error(error.toString()));
    }
  }

  Future<Option<Error>> confirmEmail(
    String email,
    String confirmationCode,
  ) async {
    try {
      await _policy.execute(
        () => _accountApiService.confirmEmail(email, confirmationCode),
      );

      _notificationService.showMessage(
        'Account confirmed successfully. You can log-in now',
      );

      return None();
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return Some(Error(error.toString()));
    }
  }

  Future<Option<Error>> signIn(String email, String password) async {
    try {
      var account = await _storage.loadAccount();

      var response = await _policy.execute(
        () => _accountApiService.signIn(
          account.deviceId,
          email,
          password,
        ),
      );

      account = AccountEntity.user(
        deviceId: account.deviceId,
        email: email,
        username: response.username,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      await _storage.saveAccount(account);

      await _serverConnector.setTokensAndRestartConnections(
        account.accessToken,
        account.refreshToken,
      );

      return None();
    } catch (error) {
      _notificationService.showMessage(error.toString());
      return Some(Error(error.toString()));
    }
  }

  Future refreshAccessToken() async {
    var account = await _storage.loadAccount();

    var response = await _policy.execute(
      () => _accountApiService.refreshAccessToken(
        account.deviceId,
        account.accessToken,
        account.refreshToken,
      ),
    );

    account = AccountEntity.user(
      deviceId: account.deviceId,
      email: account.email,
      username: account.username,
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    await _storage.saveAccount(account);

    await _serverConnector.setTokensAndRestartConnections(
      account.accessToken,
      account.refreshToken,
    );
  }

  // Future<Option<Error>> updateProfileImage(File imageFile) async {
  //   try {
  //     var account = await _storage.loadAccount();

  //     var resizedImageBytes = await _imageService.resizeImage(imageFile);

  //     await _policy.execute(
  //       () => _accountApiService.updateProfileImage(
  //         resizedImageBytes,
  //         '${account.username}.png',
  //       ),
  //     );

  //     await _imageService.invalidateCachedProfileImage(account.username);

  //     return None();
  //   } catch (error, stackTrace) {
  //     print('===== $error =====');
  //     print(stackTrace);

  //     return Some(Error(error.toString()));
  //   }
  // }
}
