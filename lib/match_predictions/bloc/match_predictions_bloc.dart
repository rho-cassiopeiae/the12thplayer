import 'dart:async';

import 'match_predictions_actions.dart';
import 'match_predictions_states.dart';
import '../../general/bloc/bloc.dart';
import '../services/match_predictions_service.dart';

class MatchPredictionsBloc extends Bloc<MatchPredictionsAction> {
  final MatchPredictionsService _matchPredictionsService;

  StreamController<LoadActiveFixturesState> _activeFixturesStateChannel =
      StreamController<LoadActiveFixturesState>.broadcast();
  Stream<LoadActiveFixturesState> get activeFixturesState$ =>
      _activeFixturesStateChannel.stream;

  MatchPredictionsBloc(this._matchPredictionsService) {
    actionChannel.stream.listen((action) {
      if (action is LoadActiveFixtures) {
        _loadActiveFixtures(action);
      } else if (action is AddDraftPrediction) {
        _addDraftPrediction(action);
      } else if (action is SubmitMatchPredictions) {
        _submitMatchPredictions(action);
      }
    });
  }

  @override
  void dispose({MatchPredictionsAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _activeFixturesStateChannel.close();
    _activeFixturesStateChannel = null;
  }

  void _loadActiveFixtures(LoadActiveFixtures action) async {
    var seasonRound = await _matchPredictionsService.loadActiveFixtures(
      action.clearDraftPredictions,
    );
    if (seasonRound != null) {
      _activeFixturesStateChannel?.add(
        ActiveFixturesReady(seasonRound: seasonRound),
      );
    }
  }

  void _addDraftPrediction(AddDraftPrediction action) {
    var seasonRound = _matchPredictionsService.addDraftPrediction(
      action.fixtureId,
      action.score,
    );
    if (seasonRound != null) {
      _activeFixturesStateChannel?.add(
        ActiveFixturesReady(seasonRound: seasonRound),
      );
    }
  }

  void _submitMatchPredictions(SubmitMatchPredictions action) async {
    var seasonRound = await _matchPredictionsService.submitMatchPredictions();
    if (seasonRound != null) {
      _activeFixturesStateChannel?.add(
        ActiveFixturesReady(seasonRound: seasonRound),
      );
    }
  }
}
