import 'package:flutter/material.dart';

class ErrorNotificationService {
  GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  void addScaffoldMessengerKey(
    GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  ) {
    _scaffoldMessengerKey = scaffoldMessengerKey;
  }

  void showErrorMessage(String message) {
    _scaffoldMessengerKey.currentState.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
