import 'account_states.dart';
import '../services/account_service.dart';
import 'account_actions.dart';
import '../../general/bloc/bloc.dart';

class AccountBloc extends Bloc<AccountAction> {
  final AccountService _accountService;

  AccountBloc(this._accountService) {
    actionChannel.stream.listen((action) {
      if (action is LoadAccount) {
        _loadAccount(action);
      } else if (action is SignUp) {
        _signUp(action);
      } else if (action is ConfirmEmail) {
        _confirmEmail(action);
      } else if (action is ResumeInterruptedConfirmation) {
        _resumeInterruptedConfirmation(action);
      } else if (action is SignIn) {
        _signIn(action);
      } else if (action is UpdateProfileImage) {
        _updateProfileImage(action);
      }
    });
  }

  @override
  void dispose({AccountAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
  }

  void _loadAccount(LoadAccount action) async {
    var account = await _accountService.loadAccount();
    var state = account.fold(
      (error) => AccountError(),
      (account) => AccountReady(account: account),
    );

    action.complete(state);
  }

  void _signUp(SignUp action) async {
    // @@TODO: Validation.
    var result = await _accountService.signUp(
      action.email,
      action.username,
      action.password,
    );

    var state = result.fold(
      (error) => AuthError(message: error.toString()),
      (account) => AuthSuccess(account: account),
    );

    action.complete(state);
  }

  void _confirmEmail(ConfirmEmail action) async {
    // @@TODO: Validation.
    var result = await _accountService.confirmEmail(action.confirmationCode);

    var state = result.fold(
      (error) => AuthError(message: error.toString()),
      (account) => AuthSuccess(account: account),
    );

    action.complete(state);
  }

  void _resumeInterruptedConfirmation(
    ResumeInterruptedConfirmation action,
  ) async {
    // @@TODO: Validation.
    var result = await _accountService.resumeInterruptedConfirmation(
      action.password,
    );

    var state = result.fold(
      (error) => AuthError(message: error.toString()),
      (account) => AuthSuccess(account: account),
    );

    action.complete(state);
  }

  void _signIn(SignIn action) async {
    // @@TODO: Validation.
    var result = await _accountService.signIn(action.email, action.password);

    var state = result.fold(
      (error) => AuthError(message: error.toString()),
      (account) => AuthSuccess(account: account),
    );

    action.complete(state);
  }

  void _updateProfileImage(UpdateProfileImage action) async {
    var result = await _accountService.updateProfileImage(action.imageFile);

    var state = result.fold(
      () => UpdateProfileImageReady(),
      (error) => UpdateProfileImageError(message: error.toString()),
    );

    action.complete(state);
  }
}
