import 'package:flutter/foundation.dart';

abstract class FixtureCalendarAction {}

class LoadFixtureCalendar extends FixtureCalendarAction {
  final int page;

  LoadFixtureCalendar({@required this.page});
}
