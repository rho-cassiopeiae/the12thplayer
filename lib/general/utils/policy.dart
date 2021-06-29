import 'dart:async';

import 'package:flutter/foundation.dart';

bool any(_) => true;

class When<TException> {
  final bool Function(TException) condition;
  final int repeat;
  final Future Function() afterDoing;
  final Duration Function(int) withInterval;

  Type get _exceptionType => TException;

  bool _evaluateCondition(dynamic error) => condition(error);

  When(
    this.condition, {
    @required this.repeat,
    this.afterDoing,
    this.withInterval,
  });
}

class _Configuration {
  final Type exceptionType;
  final int maxRepeats;
  final List<When> strategies;

  _Configuration(
    this.exceptionType,
    this.maxRepeats,
    this.strategies,
  );
}

class PolicyBuilder {
  final List<_Configuration> _configurations = [];

  PolicyBuilder on<TException>({
    int maxRepeats,
    @required List<When<TException>> strategies,
  }) {
    if (maxRepeats == null) {
      maxRepeats = strategies.fold(
        0,
        (repeats, strategy) => repeats + strategy.repeat,
      );
    }

    _configurations.add(
      _Configuration(
        strategies.first._exceptionType,
        maxRepeats,
        strategies,
      ),
    );

    return this;
  }

  Policy build() => Policy(
        _configurations.fold(0, (repeats, c) => repeats + c.maxRepeats),
        _configurations,
      );
}

class Policy {
  final int _maxRepeats;
  final List<_Configuration> _configurations;

  Policy(this._maxRepeats, this._configurations);

  Future<TResult> execute<TResult>(FutureOr<TResult> Function() f) async {
    int totalRepeats = -1;
    var repeats = _configurations
        .map((c) => List<int>.filled(c.strategies.length, -1))
        .toList();

    outer:
    while (true) {
      try {
        TResult result = await f();
        return result;
      } catch (error) {
        if (++totalRepeats < _maxRepeats) {
          for (int i = 0; i < _configurations.length; ++i) {
            var c = _configurations[i];
            if (error.runtimeType == c.exceptionType) {
              for (int j = 0; j < c.strategies.length; ++j) {
                var strategy = c.strategies[j];
                if (strategy._evaluateCondition(error)) {
                  if (++repeats[i][j] < strategy.repeat) {
                    if (strategy.afterDoing != null) {
                      await strategy.afterDoing();
                    }
                    if (strategy.withInterval != null) {
                      await Future.delayed(
                        strategy.withInterval(repeats[i][j]),
                      );
                    }
                    continue outer;
                  }

                  break;
                }
              }

              break;
            }
          }
        }

        rethrow;
      }
    }
  }
}
