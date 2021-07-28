import '../../../common/models/entities/fixture_entity.dart';
import '../../../common/models/vm/fixture_summary_vm.dart';
import '../../models/vm/stats_vm.dart';
import '../../../../team/models/entities/team_entity.dart';
import 'colors_vm.dart';
import 'lineups_vm.dart';
import 'match_events_vm.dart';

class FixtureFullVm extends FixtureSummaryVm {
  final String refereeName;
  final ColorsVm colors;
  final LineupsVm lineups;
  final MatchEventsVm events;
  final StatsVm stats;

  FixtureFullVm.fromEntity(
    TeamEntity team,
    FixtureEntity fixture,
  )   : refereeName = fixture.refereeName,
        colors = ColorsVm.fromEntity(fixture),
        lineups = LineupsVm.fromEntity(fixture),
        events = MatchEventsVm.fromEntity(fixture),
        stats = StatsVm.fromEntity(fixture),
        super.fromEntity(team, fixture);
}
