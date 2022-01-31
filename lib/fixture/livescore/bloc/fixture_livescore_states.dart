import 'package:flutter/foundation.dart';

import '../models/vm/fixture_full_vm.dart';

abstract class FixtureLivescoreState {}

abstract class LoadFixtureState extends FixtureLivescoreState {}

class FixtureLoading extends LoadFixtureState {}

class FixtureReady extends LoadFixtureState {
  final FixtureFullVm fixture;
  final bool shouldSubscribe;

  FixtureReady({
    @required this.fixture,
    this.shouldSubscribe,
  });
}
