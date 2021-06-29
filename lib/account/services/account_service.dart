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

      var confirmedAccount = AccountEntity.confirmed(
        email: account.email,
        username: account.username,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      await _storage.saveAccount(confirmedAccount);

      await _serverConnector.setTokensAndAbortConnection(
        confirmedAccount.accessToken,
        confirmedAccount.refreshToken,
      );

      return Right(AccountVm.fromEntity(confirmedAccount));
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
      if (response.accessToken != null) {
        account = AccountEntity.confirmed(
          email: email,
          username: response.username,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        );

        await _serverConnector.setTokensAndAbortConnection(
          account.accessToken,
          account.refreshToken,
        );
      } else {
        account = AccountEntity.unconfirmed(
          email: email,
          username: response.username,
        );
      }

      await _storage.saveAccount(account);

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
