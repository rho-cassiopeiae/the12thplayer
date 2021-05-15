import 'package:flutter/foundation.dart';

import '../models/vm/fixture_full_vm.dart';

abstract class FixtureLivescoreState {}

class FixtureLoading extends FixtureLivescoreState {}

class FixtureReady extends FixtureLivescoreState {
  final FixtureFullVm fixture;

  FixtureReady({@required this.fixture});
}

class FixtureError extends FixtureLivescoreState {
  final String message;

  FixtureError({@required this.message});
}
