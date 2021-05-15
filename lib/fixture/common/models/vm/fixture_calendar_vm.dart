import 'package:flutter/foundation.dart';

import 'fixture_summary_vm.dart';

class FixtureCalendarVm {
  final String year;
  final String month;
  final List<FixtureSummaryVm> fixtures;

  FixtureCalendarVm({
    @required this.year,
    @required this.month,
    @required this.fixtures,
  });
}
