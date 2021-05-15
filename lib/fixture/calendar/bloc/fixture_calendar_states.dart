import 'package:flutter/foundation.dart';

import '../../common/models/vm/fixture_calendar_vm.dart';

abstract class FixtureCalendarState {}

class FixtureCalendarLoading extends FixtureCalendarState {}

class FixtureCalendarReady extends FixtureCalendarState {
  final FixtureCalendarVm fixtureCalendar;

  FixtureCalendarReady({@required this.fixtureCalendar});
}

class FixtureCalendarError extends FixtureCalendarState {
  final String message;

  FixtureCalendarError({@required this.message});
}
