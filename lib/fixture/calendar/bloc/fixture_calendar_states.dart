import 'package:flutter/foundation.dart';

import '../../common/models/vm/fixture_calendar_vm.dart';

abstract class FixtureCalendarState {}

abstract class LoadFixtureCalendarState extends FixtureCalendarState {}

class FixtureCalendarLoading extends LoadFixtureCalendarState {}

class FixtureCalendarReady extends LoadFixtureCalendarState {
  final FixtureCalendarVm fixtureCalendar;

  FixtureCalendarReady({@required this.fixtureCalendar});
}

class FixtureCalendarError extends LoadFixtureCalendarState {
  final String message;

  FixtureCalendarError({@required this.message});
}
