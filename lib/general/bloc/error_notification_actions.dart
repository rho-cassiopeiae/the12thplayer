import 'package:flutter/material.dart';

abstract class ErrorNotificationAction {}

class AddScaffoldMessengerKey extends ErrorNotificationAction {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  AddScaffoldMessengerKey({@required this.scaffoldMessengerKey});
}
