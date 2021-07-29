import 'bloc.dart';
import 'notification_actions.dart';
import '../services/notification_service.dart';

class NotificationBloc extends Bloc<NotificationAction> {
  final NotificationService _notificationService;

  NotificationBloc(this._notificationService) {
    actionChannel.stream.listen((action) {
      if (action is AddScaffoldMessengerKey) {
        _addScaffoldMessengerKey(action);
      }
    });
  }

  @override
  void dispose({NotificationAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
  }

  void _addScaffoldMessengerKey(AddScaffoldMessengerKey action) {
    _notificationService.addScaffoldMessengerKey(action.scaffoldMessengerKey);
  }
}
