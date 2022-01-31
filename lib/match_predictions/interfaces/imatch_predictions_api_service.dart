import '../models/dto/match_predictions_submission_dto.dart';
import '../models/dto/active_season_round_with_fixtures_dto.dart';

abstract class IMatchPredictionsApiService {
  Future<Iterable<ActiveSeasonRoundWithFixturesDto>> getActiveFixturesForTeam(
    int teamId,
  );

  Future<MatchPredictionsSubmissionDto> submitMatchPredictions(
    int seasonId,
    int roundId,
    Map<int, String> fixtureIdToScore,
  );
}
