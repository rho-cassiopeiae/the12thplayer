import 'package:flutter/foundation.dart';

import '../models/vm/performance_ratings_vm.dart';

abstract class PerformanceRatingState {}

abstract class LoadPerformanceRatingsState extends PerformanceRatingState {}

class PerformanceRatingsLoading extends LoadPerformanceRatingsState {}

class PerformanceRatingsReady extends LoadPerformanceRatingsState {
  final PerformanceRatingsVm performanceRatings;

  PerformanceRatingsReady({@required this.performanceRatings});
}

class PerformanceRatingsError extends LoadPerformanceRatingsState {
  final String message;

  PerformanceRatingsError({@required this.message});
}
