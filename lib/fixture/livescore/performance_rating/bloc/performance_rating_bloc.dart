import 'dart:async';

import 'performance_rating_actions.dart';
import 'performance_rating_states.dart';
import '../services/performance_rating_service.dart';
import '../../../../general/bloc/bloc.dart';

class PerformanceRatingBloc extends Bloc<PerformanceRatingAction> {
  final PerformanceRatingService _performanceRatingService;

  StreamController<LoadPerformanceRatingsState> _stateChannel =
      StreamController<LoadPerformanceRatingsState>.broadcast();
  Stream<LoadPerformanceRatingsState> get state$ => _stateChannel.stream;

  PerformanceRatingBloc(this._performanceRatingService) {
    actionChannel.stream.listen((action) {
      if (action is LoadPerformanceRatings) {
        _loadPerformanceRatings(action);
      } else if (action is RateParticipantOfGivenFixture) {
        _rateParticipantOfGivenFixture(action);
      }
    });
  }

  @override
  void dispose({PerformanceRatingAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _stateChannel.close();
    _stateChannel = null;
  }

  void _loadPerformanceRatings(LoadPerformanceRatings action) async {
    var result = await _performanceRatingService.loadPerformanceRatings(
      action.fixtureId,
    );

    var state = result.fold(
      (error) => PerformanceRatingsError(message: error.toString()),
      (performanceRatings) =>
          PerformanceRatingsReady(performanceRatings: performanceRatings),
    );

    _stateChannel?.add(state);
  }

  void _rateParticipantOfGivenFixture(
    RateParticipantOfGivenFixture action,
  ) async {
    var performanceRatings =
        await _performanceRatingService.rateParticipantOfGivenFixture(
      action.fixtureId,
      action.participantIdentifier,
      action.rating,
    );

    _stateChannel?.add(
      PerformanceRatingsReady(performanceRatings: performanceRatings),
    );
  }
}
