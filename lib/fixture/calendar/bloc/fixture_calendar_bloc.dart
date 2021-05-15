import 'dart:async';

import '../services/fixture_calendar_service.dart';
import '../../../general/bloc/bloc.dart';
import 'fixture_calendar_states.dart';
import 'fixture_calendar_actions.dart';

class FixtureCalendarBloc extends Bloc<FixtureCalendarAction> {
  final FixtureCalendarService _fixtureCalendarService;

  StreamController<FixtureCalendarState> _stateChannel =
      StreamController<FixtureCalendarState>.broadcast();
  Stream<FixtureCalendarState> get state$ => _stateChannel.stream;

  FixtureCalendarBloc(this._fixtureCalendarService) {
    actionChannel.stream.listen((action) {
      if (action is LoadFixtures) {
        _loadFixtures(action);
      }
    });
  }

  @override
  void dispose({FixtureCalendarAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _stateChannel.close();
    _stateChannel = null;
  }

  void _loadFixtures(LoadFixtures action) async {
    await for (var result in _fixtureCalendarService.loadFixtures(
      action.page,
    )) {
      var state = result.fold(
        (error) => FixtureCalendarError(message: error.toString()),
        (fixtureCalendar) => FixtureCalendarReady(
          fixtureCalendar: fixtureCalendar,
        ),
      );

      _stateChannel?.add(state);
    }
  }
}
