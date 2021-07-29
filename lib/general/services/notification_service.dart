import 'package:flutter/material.dart';

class NotificationService {
  GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  void addScaffoldMessengerKey(
    GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  ) {
    _scaffoldMessengerKey = scaffoldMessengerKey;
  }

  void showMessage(String message) {
    _scaffoldMessengerKey.currentState.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // @@TODO: Config.
      ),
    );
  }
}
