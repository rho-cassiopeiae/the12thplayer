import '../../common/models/entities/fixture_entity.dart';

abstract class IFixtureCalendarRepository {
  Future<Iterable<FixtureEntity>> loadFixturesForTeamInBetween(
    int teamId,
    DateTime startTime,
    DateTime endTime,
  );

  Future saveFixtures(Iterable<FixtureEntity> fixtures);
}
