import 'dart:async';

import 'package:flutter/foundation.dart';

class When<TException> {
  final bool Function(TException) condition;
  final int repeat;
  final Future Function() afterDoing;
  final Duration Function(int) withInterval;

  When(
    this.condition, {
    @required this.repeat,
    this.afterDoing,
    this.withInterval,
  });
}

bool any(_) => true;

class Policy {
  static PolicyExecutor<TException> on<TException>({
    int maxRepeats,
    @required List<When<TException>> strategies,
  }) {
    if (maxRepeats == null) {
      maxRepeats = strategies.fold(
        0,
        (repeats, strategy) => repeats + strategy.repeat,
      );
    }

    return PolicyExecutor(maxRepeats, strategies);
  }
}

class PolicyExecutor<TException1> {
  final int _maxRepeats;
  final List<When<TException1>> _strategies;

  PolicyExecutor(this._maxRepeats, this._strategies);

  PolicyExecutor2<TException1, TException2> on<TException2>({
    int maxRepeats,
    @required List<When<TException2>> strategies,
  }) {
    if (maxRepeats == null) {
      maxRepeats = strategies.fold(
        0,
        (repeats, strategy) => repeats + strategy.repeat,
      );
    }

    return PolicyExecutor2(
      _maxRepeats + maxRepeats,
      _strategies,
      strategies,
    );
  }

  Future<TResult> execute<TResult>(FutureOr<TResult> Function() f) async {
    int totalRepeats = -1;
    var repeats = List<int>.filled(_strategies.length, -1);

    outer:
    while (true) {
      try {
        TResult result = await f();
        return result;
      } on TException1 catch (error) {
        if (++totalRepeats < _maxRepeats) {
          for (int i = 0; i < _strategies.length; ++i) {
            var strategy = _strategies[i];
            if (strategy.condition(error)) {
              if (++repeats[i] < strategy.repeat) {
                if (strategy.afterDoing != null) {
                  await strategy.afterDoing();
                }
                if (strategy.withInterval != null) {
                  await Future.delayed(strategy.withInterval(repeats[i]));
                }
                continue outer;
              }

              rethrow;
            }
          }
        }

        rethrow;
      }
    }
  }
}

class PolicyExecutor2<TException1, TException2> {
  final int _maxRepeats;
  final List<When<TException1>> _strategies1;
  final List<When<TException2>> _strategies2;

  PolicyExecutor2(
    this._maxRepeats,
    this._strategies1,
    this._strategies2,
  );

  PolicyExecutor3<TException1, TException2, TException3> on<TException3>({
    int maxRepeats,
    @required List<When<TException3>> strategies,
  }) {
    if (maxRepeats == null) {
      maxRepeats = strategies.fold(
        0,
        (repeats, strategy) => repeats + strategy.repeat,
      );
    }

    return PolicyExecutor3(
      _maxRepeats + maxRepeats,
      _strategies1,
      _strategies2,
      strategies,
    );
  }

  Future<TResult> execute<TResult>(FutureOr<TResult> Function() f) async {
    int totalRepeats = -1;
    var repeats1 = List<int>.filled(_strategies1.length, -1);
    var repeats2 = List<int>.filled(_strategies2.length, -1);

    outer:
    while (true) {
      try {
        TResult result = await f();
        return result;
      } on TException1 catch (error) {
        if (++totalRepeats < _maxRepeats) {
          for (int i = 0; i < _strategies1.length; ++i) {
            var strategy = _strategies1[i];
            if (strategy.condition(error)) {
              if (++repeats1[i] < strategy.repeat) {
                if (strategy.afterDoing != null) {
                  await strategy.afterDoing();
                }
                if (strategy.withInterval != null) {
                  await Future.delayed(strategy.withInterval(repeats1[i]));
                }
                continue outer;
              }

              rethrow;
            }
          }
        }

        rethrow;
      } on TException2 catch (error) {
        if (++totalRepeats < _maxRepeats) {
          for (int i = 0; i < _strategies2.length; ++i) {
            var strategy = _strategies2[i];
            if (strategy.condition(error)) {
              if (++repeats2[i] < strategy.repeat) {
                if (strategy.afterDoing != null) {
                  await strategy.afterDoing();
                }
                if (strategy.withInterval != null) {
                  await Future.delayed(strategy.withInterval(repeats2[i]));
                }
                continue outer;
              }

              rethrow;
            }
          }
        }

        rethrow;
      }
    }
  }
}

class PolicyExecutor3<TException1, TException2, TException3> {
  final int _maxRepeats;
  final List<When<TException1>> _strategies1;
  final List<When<TException2>> _strategies2;
  final List<When<TException3>> _strategies3;

  PolicyExecutor3(
    this._maxRepeats,
    this._strategies1,
    this._strategies2,
    this._strategies3,
  );

  Future<TResult> execute<TResult>(FutureOr<TResult> Function() f) async {
    int totalRepeats = -1;
    var repeats1 = List<int>.filled(_strategies1.length, -1);
    var repeats2 = List<int>.filled(_strategies2.length, -1);
    var repeats3 = List<int>.filled(_strategies3.length, -1);

    outer:
    while (true) {
      try {
        TResult result = await f();
        return result;
      } on TException1 catch (error) {
        if (++totalRepeats < _maxRepeats) {
          for (int i = 0; i < _strategies1.length; ++i) {
            var strategy = _strategies1[i];
            if (strategy.condition(error)) {
              if (++repeats1[i] < strategy.repeat) {
                if (strategy.afterDoing != null) {
                  await strategy.afterDoing();
                }
                if (strategy.withInterval != null) {
                  await Future.delayed(strategy.withInterval(repeats1[i]));
                }
                continue outer;
              }

              rethrow;
            }
          }
        }

        rethrow;
      } on TException2 catch (error) {
        if (++totalRepeats < _maxRepeats) {
          for (int i = 0; i < _strategies2.length; ++i) {
            var strategy = _strategies2[i];
            if (strategy.condition(error)) {
              if (++repeats2[i] < strategy.repeat) {
                if (strategy.afterDoing != null) {
                  await strategy.afterDoing();
                }
                if (strategy.withInterval != null) {
                  await Future.delayed(strategy.withInterval(repeats2[i]));
                }
                continue outer;
              }

              rethrow;
            }
          }
        }

        rethrow;
      } on TException3 catch (error) {
        if (++totalRepeats < _maxRepeats) {
          for (int i = 0; i < _strategies3.length; ++i) {
            var strategy = _strategies3[i];
            if (strategy.condition(error)) {
              if (++repeats3[i] < strategy.repeat) {
                if (strategy.afterDoing != null) {
                  await strategy.afterDoing();
                }
                if (strategy.withInterval != null) {
                  await Future.delayed(strategy.withInterval(repeats3[i]));
                }
                continue outer;
              }

              rethrow;
            }
          }
        }

        rethrow;
      }
    }
  }
}
