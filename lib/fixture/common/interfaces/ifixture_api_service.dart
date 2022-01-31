import '../../livescore/models/dto/fixture_livescore_update_dto.dart';
import '../../livescore/models/dto/fixture_full_dto.dart';
import '../models/dto/fixture_summary_dto.dart';

abstract class IFixtureApiService {
  Future<Iterable<FixtureSummaryDto>> getFixturesForTeamInBetween(
    int teamId,
    int startTime,
    int endTime,
  );

  Future<FixtureFullDto> getFixtureForTeam(int fixtureId, int teamId);

  Future<Stream<FixtureLivescoreUpdateDto>> subscribeToFixture(
    int fixtureId,
    int teamId,
  );

  Future unsubscribeFromFixture(int fixtureId, int teamId);
}
