import '../../common/models/entities/fixture_entity.dart';

abstract class IFixtureRepository {
  Future<FixtureEntity> loadFixtureForTeam(int fixtureId, int teamId);
  Future updateFixture(FixtureEntity fixture);
  Future<FixtureEntity> updateFixtureFromLivescore(FixtureEntity fixture);
}
