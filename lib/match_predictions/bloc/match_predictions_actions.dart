import 'package:flutter/foundation.dart';

abstract class MatchPredictionsAction {}

class LoadActiveFixtures extends MatchPredictionsAction {
  final bool clearDraftPredictions;

  LoadActiveFixtures({@required this.clearDraftPredictions});
}

class AddDraftPrediction extends MatchPredictionsAction {
  final int fixtureId;
  final String score;

  AddDraftPrediction({
    @required this.fixtureId,
    @required this.score,
  });
}

class SubmitMatchPredictions extends MatchPredictionsAction {}
