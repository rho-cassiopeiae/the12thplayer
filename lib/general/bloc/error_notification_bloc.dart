import 'bloc.dart';
import 'error_notification_actions.dart';
import '../services/error_notification_service.dart';

class ErrorNotificationBloc extends Bloc<ErrorNotificationAction> {
  final ErrorNotificationService _errorNotificationService;

  ErrorNotificationBloc(this._errorNotificationService) {
    actionChannel.stream.listen((action) {
      if (action is AddScaffoldMessengerKey) {
        _addScaffoldMessengerKey(action);
      }
    });
  }

  @override
  void dispose({ErrorNotificationAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
  }

  void _addScaffoldMessengerKey(AddScaffoldMessengerKey action) {
    _errorNotificationService
        .addScaffoldMessengerKey(action.scaffoldMessengerKey);
  }
}
