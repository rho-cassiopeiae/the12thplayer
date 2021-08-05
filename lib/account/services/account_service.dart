import 'dart:io';
import 'dart:math';

import 'package:either_option/either_option.dart';

import '../enums/account_type.dart';
import '../interfaces/iaccount_api_service.dart';
import '../models/entities/account_entity.dart';
import '../models/vm/account_vm.dart';
import '../../general/errors/authentication_token_expired_error.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../../general/interfaces/iimage_service.dart';
import '../../general/persistence/storage.dart';
import '../../general/services/server_connector.dart';
import '../../general/utils/policy.dart';
import '../../general/errors/error.dart';

class AccountService {
  final Storage _storage;
  final ServerConnector _serverConnector;
  final IAccountApiService _accountApiService;
  final IImageService _imageService;

  Policy _apiPolicy;

  AccountService(
    this._storage,
    this._serverConnector,
    this._accountApiService,
    this._imageService,
  ) {
    _apiPolicy = PolicyBuilder().on<ConnectionError>(
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
    ).on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: refreshAccessToken,
        ),
      ],
    ).build();
  }

  Future<Either<Error, AccountVm>> loadAccount() async {
    try {
      var account = await _storage.loadAccount();
      if (account.type == AccountType.ConfirmedAccount) {
        _serverConnector.setTokens(account.accessToken, account.refreshToken);
      }

      return Right(AccountVm.fromEntity(account));
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Future<Either<Error, AccountVm>> signUp(
    String email,
    String username,
    String password,
  ) async {
    try {
      await _apiPolicy.execute(
        () => _accountApiService.signUp(email, username, password),
      );

      var account = AccountEntity.unconfirmed(
        email: email,
        username: username,
      );

      await _storage.saveAccount(account);

      return Right(AccountVm.fromEntity(account));
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Future<AccountEntity> _createProfileAndSaveAccount(
    String email,
    String username,
    String accessToken,
    String refreshToken,
  ) async {
    await _apiPolicy.execute(
      () => _accountApiService.createProfile(
        accessToken,
        email,
      ),
    );

    var account = AccountEntity.confirmed(
      email: email,
      username: username,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    await _storage.saveAccount(account);

    await _serverConnector.setTokensAndAbortConnection(
      accessToken,
      refreshToken,
    );

    return account;
  }

  Future<Either<Error, AccountVm>> confirmEmail(
    String confirmationCode,
  ) async {
    try {
      var account = await _storage.loadAccount();

      var response = await _apiPolicy.execute(
        () => _accountApiService.confirmEmail(
          account.email,
          confirmationCode,
        ),
      );

      account = await _createProfileAndSaveAccount(
        account.email,
        account.username,
        response.accessToken,
        response.refreshToken,
      );

      return Right(AccountVm.fromEntity(account));
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Future<Either<Error, AccountVm>> resumeInterruptedConfirmation(
    String password,
  ) async {
    try {
      var account = await _storage.loadAccount();

      var response = await _apiPolicy.execute(
        () => _accountApiService.signIn(
          account.email,
          password,
        ),
      );

      // @@NOTE: Can only get here if account is confirmed, so no need to check the response.
      account = await _createProfileAndSaveAccount(
        account.email,
        response.username,
        response.accessToken,
        response.refreshToken,
      );

      return Right(AccountVm.fromEntity(account));
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Future<Either<Error, AccountVm>> signIn(
    String email,
    String password,
  ) async {
    try {
      var response = await _apiPolicy.execute(
        () => _accountApiService.signIn(
          email,
          password,
        ),
      );

      AccountEntity account;
      if (response.accessToken == null) {
        account = AccountEntity.unconfirmed(
          email: email,
          username: response.username,
        );

        await _storage.saveAccount(account);
      } else {
        // @@NOTE: Creating profile is idempotent. We need to create a profile upon login
        // to account for the possibility that user sent email confirmation code and his
        // email was confirmed on the server, but then he closed the app before the call
        // to create a profile could be issued. So user has a confirmed account but no profile.
        // Then imagine that he opened the app from another device and signed-in. We need to
        // finish profile creation for him, that's why we call createProfile. This is a very rare
        // case, so the call almost always does nothing on the server. It's fine, since we don't
        // expect users to sign-in a lot — they sign-up/sign-in once and just keep using the app.
        account = await _createProfileAndSaveAccount(
          email,
          response.username,
          response.accessToken,
          response.refreshToken,
        );
      }

      return Right(AccountVm.fromEntity(account));
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Future refreshAccessToken() async {
    var response = await _apiPolicy.execute(
      _accountApiService.refreshAccessToken,
    );

    var account = await _storage.loadAccount();
    account = AccountEntity.confirmed(
      email: account.email,
      username: account.username,
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    await _storage.saveAccount(account);

    await _serverConnector.setTokensAndAbortConnection(
      account.accessToken,
      account.refreshToken,
    );
  }

  Future<Option<Error>> updateProfileImage(File imageFile) async {
    try {
      var account = await _storage.loadAccount();

      var resizedImageBytes = await _imageService.resizeImage(imageFile);

      await _apiPolicy.execute(
        () => _accountApiService.updateProfileImage(
          resizedImageBytes,
          '${account.username}.png',
        ),
      );

      await _imageService.invalidateCachedProfileImage(account.username);

      return None();
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Some(Error(error.toString()));
    }
  }
}
