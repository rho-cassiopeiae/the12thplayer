import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart';

extension KiwiExtension on KiwiContainer {
  static final Map<String, Object> _identifierToInstance = {};

  TDependency resolveInstance<TDependency>(
    String dependencyInstanceIdentifier,
  ) {
    if (!_identifierToInstance.containsKey(dependencyInstanceIdentifier)) {
      _identifierToInstance[dependencyInstanceIdentifier] =
          resolve<TDependency>();
    }

    return _identifierToInstance[dependencyInstanceIdentifier] as TDependency;
  }
}

mixin DependencyResolver<TDependency> {
  TDependency resolve([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency>()
          : KiwiContainer().resolveInstance<TDependency>(
              dependencyInstanceIdentifier,
            );
}

mixin DependencyResolver2<TDependency1, TDependency2> {
  TDependency1 resolve1([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency1>()
          : KiwiContainer().resolveInstance<TDependency1>(
              dependencyInstanceIdentifier,
            );

  TDependency2 resolve2([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency2>()
          : KiwiContainer().resolveInstance<TDependency2>(
              dependencyInstanceIdentifier,
            );
}

mixin DependencyResolver3<TDependency1, TDependency2, TDependency3> {
  TDependency1 resolve1([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency1>()
          : KiwiContainer().resolveInstance<TDependency1>(
              dependencyInstanceIdentifier,
            );

  TDependency2 resolve2([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency2>()
          : KiwiContainer().resolveInstance<TDependency2>(
              dependencyInstanceIdentifier,
            );

  TDependency3 resolve3([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency3>()
          : KiwiContainer().resolveInstance<TDependency3>(
              dependencyInstanceIdentifier,
            );
}

mixin DependencyResolver4<TDependency1, TDependency2, TDependency3,
    TDependency4> {
  TDependency1 resolve1([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency1>()
          : KiwiContainer().resolveInstance<TDependency1>(
              dependencyInstanceIdentifier,
            );

  TDependency2 resolve2([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency2>()
          : KiwiContainer().resolveInstance<TDependency2>(
              dependencyInstanceIdentifier,
            );

  TDependency3 resolve3([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency3>()
          : KiwiContainer().resolveInstance<TDependency3>(
              dependencyInstanceIdentifier,
            );

  TDependency4 resolve4([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency4>()
          : KiwiContainer().resolveInstance<TDependency4>(
              dependencyInstanceIdentifier,
            );
}

mixin DependencyResolver5<TDependency1, TDependency2, TDependency3,
    TDependency4, TDependency5> {
  TDependency1 resolve1([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency1>()
          : KiwiContainer().resolveInstance<TDependency1>(
              dependencyInstanceIdentifier,
            );

  TDependency2 resolve2([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency2>()
          : KiwiContainer().resolveInstance<TDependency2>(
              dependencyInstanceIdentifier,
            );

  TDependency3 resolve3([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency3>()
          : KiwiContainer().resolveInstance<TDependency3>(
              dependencyInstanceIdentifier,
            );

  TDependency4 resolve4([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency4>()
          : KiwiContainer().resolveInstance<TDependency4>(
              dependencyInstanceIdentifier,
            );

  TDependency5 resolve5([String dependencyInstanceIdentifier]) =>
      dependencyInstanceIdentifier == null
          ? KiwiContainer().resolve<TDependency5>()
          : KiwiContainer().resolveInstance<TDependency5>(
              dependencyInstanceIdentifier,
            );
}

abstract class StatelessWidgetInjected<TDependency> extends StatelessWidget
    with DependencyResolver<TDependency> {
  final String _dependencyInstanceIdentifier;

  StatelessWidgetInjected([this._dependencyInstanceIdentifier]);

  @override
  Widget build(BuildContext context) {
    return buildInjected(context, resolve(_dependencyInstanceIdentifier));
  }

  Widget buildInjected(BuildContext context, TDependency service);
}

abstract class StatelessWidgetInjected2<TDependency1, TDependency2>
    extends StatelessWidget
    with DependencyResolver2<TDependency1, TDependency2> {
  final String _dependencyInstanceIdentifier1;
  final String _dependencyInstanceIdentifier2;

  StatelessWidgetInjected2([
    this._dependencyInstanceIdentifier1,
    this._dependencyInstanceIdentifier2,
  ]);

  @override
  Widget build(BuildContext context) {
    return buildInjected(
      context,
      resolve1(_dependencyInstanceIdentifier1),
      resolve2(_dependencyInstanceIdentifier2),
    );
  }

  Widget buildInjected(
    BuildContext context,
    TDependency1 service1,
    TDependency2 service2,
  );
}

abstract class StatelessWidgetInjected3<TDependency1, TDependency2,
        TDependency3> extends StatelessWidget
    with DependencyResolver3<TDependency1, TDependency2, TDependency3> {
  final String _dependencyInstanceIdentifier1;
  final String _dependencyInstanceIdentifier2;
  final String _dependencyInstanceIdentifier3;

  StatelessWidgetInjected3([
    this._dependencyInstanceIdentifier1,
    this._dependencyInstanceIdentifier2,
    this._dependencyInstanceIdentifier3,
  ]);

  @override
  Widget build(BuildContext context) {
    return buildInjected(
      context,
      resolve1(_dependencyInstanceIdentifier1),
      resolve2(_dependencyInstanceIdentifier2),
      resolve3(_dependencyInstanceIdentifier3),
    );
  }

  Widget buildInjected(
    BuildContext context,
    TDependency1 service1,
    TDependency2 service2,
    TDependency3 service3,
  );
}

abstract class StatelessWidgetInjected4<TDependency1, TDependency2,
        TDependency3, TDependency4> extends StatelessWidget
    with
        DependencyResolver4<TDependency1, TDependency2, TDependency3,
            TDependency4> {
  final String _dependencyInstanceIdentifier1;
  final String _dependencyInstanceIdentifier2;
  final String _dependencyInstanceIdentifier3;
  final String _dependencyInstanceIdentifier4;

  StatelessWidgetInjected4([
    this._dependencyInstanceIdentifier1,
    this._dependencyInstanceIdentifier2,
    this._dependencyInstanceIdentifier3,
    this._dependencyInstanceIdentifier4,
  ]);

  @override
  Widget build(BuildContext context) {
    return buildInjected(
      context,
      resolve1(_dependencyInstanceIdentifier1),
      resolve2(_dependencyInstanceIdentifier2),
      resolve3(_dependencyInstanceIdentifier3),
      resolve4(_dependencyInstanceIdentifier4),
    );
  }

  Widget buildInjected(
    BuildContext context,
    TDependency1 service1,
    TDependency2 service2,
    TDependency3 service3,
    TDependency4 service4,
  );
}

abstract class StatelessWidgetInjected5<TDependency1, TDependency2,
        TDependency3, TDependency4, TDependency5> extends StatelessWidget
    with
        DependencyResolver5<TDependency1, TDependency2, TDependency3,
            TDependency4, TDependency5> {
  final String _dependencyInstanceIdentifier1;
  final String _dependencyInstanceIdentifier2;
  final String _dependencyInstanceIdentifier3;
  final String _dependencyInstanceIdentifier4;
  final String _dependencyInstanceIdentifier5;

  StatelessWidgetInjected5([
    this._dependencyInstanceIdentifier1,
    this._dependencyInstanceIdentifier2,
    this._dependencyInstanceIdentifier3,
    this._dependencyInstanceIdentifier4,
    this._dependencyInstanceIdentifier5,
  ]);

  @override
  Widget build(BuildContext context) {
    return buildInjected(
      context,
      resolve1(_dependencyInstanceIdentifier1),
      resolve2(_dependencyInstanceIdentifier2),
      resolve3(_dependencyInstanceIdentifier3),
      resolve4(_dependencyInstanceIdentifier4),
      resolve5(_dependencyInstanceIdentifier5),
    );
  }

  Widget buildInjected(
    BuildContext context,
    TDependency1 service1,
    TDependency2 service2,
    TDependency3 service3,
    TDependency4 service4,
    TDependency5 service5,
  );
}
