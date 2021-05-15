import 'package:flutter/foundation.dart';

abstract class FixtureCalendarAction {}

class LoadFixtures extends FixtureCalendarAction {
  final int page;

  LoadFixtures({@required this.page});
}
