import 'package:flutter/material.dart';

abstract class NotificationAction {}

class AddScaffoldMessengerKey extends NotificationAction {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  AddScaffoldMessengerKey({@required this.scaffoldMessengerKey});
}
