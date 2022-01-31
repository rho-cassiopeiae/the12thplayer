import 'dart:async';

import '../services/fixture_calendar_service.dart';
import '../../../general/bloc/bloc.dart';
import 'fixture_calendar_states.dart';
import 'fixture_calendar_actions.dart';

class FixtureCalendarBloc extends Bloc<FixtureCalendarAction> {
  final FixtureCalendarService _fixtureCalendarService;

  StreamController<LoadFixtureCalendarState> _fixtureCalendarStateChannel =
      StreamController<LoadFixtureCalendarState>.broadcast();
  Stream<LoadFixtureCalendarState> get fixtureCalendarState$ =>
      _fixtureCalendarStateChannel.stream;

  FixtureCalendarBloc(this._fixtureCalendarService) {
    actionChannel.stream.listen((action) {
      if (action is LoadFixtureCalendar) {
        _loadFixtureCalendar(action);
      }
    });
  }

  @override
  void dispose({FixtureCalendarAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _fixtureCalendarStateChannel.close();
    _fixtureCalendarStateChannel = null;
  }

  void _loadFixtureCalendar(LoadFixtureCalendar action) async {
    await for (var result in _fixtureCalendarService.loadFixtureCalendar(
      action.page,
    )) {
      var state = result.fold(
        (error) => FixtureCalendarError(message: error.toString()),
        (fixtureCalendar) => FixtureCalendarReady(
          fixtureCalendar: fixtureCalendar,
        ),
      );

      _fixtureCalendarStateChannel?.add(state);
    }
  }
}
