import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart';

final Map<String, Object> _identifierToInstance = {};

TDependency _resolve<TDependency>(String dependencyInstanceIdentifier) {
  TDependency instance;
  if (dependencyInstanceIdentifier == null ||
      !_identifierToInstance.containsKey(dependencyInstanceIdentifier)) {
    instance = KiwiContainer().resolve<TDependency>();
    if (dependencyInstanceIdentifier != null) {
      _identifierToInstance[dependencyInstanceIdentifier] = instance;
    }
  } else {
    instance =
        _identifierToInstance[dependencyInstanceIdentifier] as TDependency;
  }

  return instance;
}

void _dispose(String dependencyInstanceIdentifier) {
  _identifierToInstance.remove(dependencyInstanceIdentifier);
}

mixin DependencyResolver<TDependency> {
  TDependency resolve([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency>(dependencyInstanceIdentifier);

  void disposeOfDependencyInstance(String dependencyInstanceIdentifier) =>
      _dispose(dependencyInstanceIdentifier);
}

mixin DependencyResolver2<TDependency1, TDependency2> {
  TDependency1 resolve1([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency1>(dependencyInstanceIdentifier);

  TDependency2 resolve2([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency2>(dependencyInstanceIdentifier);

  void disposeOfDependencyInstance(String dependencyInstanceIdentifier) =>
      _dispose(dependencyInstanceIdentifier);
}

mixin DependencyResolver3<TDependency1, TDependency2, TDependency3> {
  TDependency1 resolve1([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency1>(dependencyInstanceIdentifier);

  TDependency2 resolve2([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency2>(dependencyInstanceIdentifier);

  TDependency3 resolve3([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency3>(dependencyInstanceIdentifier);

  void disposeOfDependencyInstance(String dependencyInstanceIdentifier) =>
      _dispose(dependencyInstanceIdentifier);
}

mixin DependencyResolver4<TDependency1, TDependency2, TDependency3,
    TDependency4> {
  TDependency1 resolve1([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency1>(dependencyInstanceIdentifier);

  TDependency2 resolve2([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency2>(dependencyInstanceIdentifier);

  TDependency3 resolve3([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency3>(dependencyInstanceIdentifier);

  TDependency4 resolve4([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency4>(dependencyInstanceIdentifier);

  void disposeOfDependencyInstance(String dependencyInstanceIdentifier) =>
      _dispose(dependencyInstanceIdentifier);
}

mixin DependencyResolver5<TDependency1, TDependency2, TDependency3,
    TDependency4, TDependency5> {
  TDependency1 resolve1([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency1>(dependencyInstanceIdentifier);

  TDependency2 resolve2([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency2>(dependencyInstanceIdentifier);

  TDependency3 resolve3([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency3>(dependencyInstanceIdentifier);

  TDependency4 resolve4([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency4>(dependencyInstanceIdentifier);

  TDependency5 resolve5([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency5>(dependencyInstanceIdentifier);

  void disposeOfDependencyInstance(String dependencyInstanceIdentifier) =>
      _dispose(dependencyInstanceIdentifier);
}

mixin DependencyResolver6<TDependency1, TDependency2, TDependency3,
    TDependency4, TDependency5, TDependency6> {
  TDependency1 resolve1([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency1>(dependencyInstanceIdentifier);

  TDependency2 resolve2([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency2>(dependencyInstanceIdentifier);

  TDependency3 resolve3([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency3>(dependencyInstanceIdentifier);

  TDependency4 resolve4([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency4>(dependencyInstanceIdentifier);

  TDependency5 resolve5([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency5>(dependencyInstanceIdentifier);

  TDependency6 resolve6([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency6>(dependencyInstanceIdentifier);

  void disposeOfDependencyInstance(String dependencyInstanceIdentifier) =>
      _dispose(dependencyInstanceIdentifier);
}

mixin DependencyResolver7<TDependency1, TDependency2, TDependency3,
    TDependency4, TDependency5, TDependency6, TDependency7> {
  TDependency1 resolve1([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency1>(dependencyInstanceIdentifier);

  TDependency2 resolve2([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency2>(dependencyInstanceIdentifier);

  TDependency3 resolve3([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency3>(dependencyInstanceIdentifier);

  TDependency4 resolve4([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency4>(dependencyInstanceIdentifier);

  TDependency5 resolve5([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency5>(dependencyInstanceIdentifier);

  TDependency6 resolve6([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency6>(dependencyInstanceIdentifier);

  TDependency7 resolve7([String dependencyInstanceIdentifier]) =>
      _resolve<TDependency7>(dependencyInstanceIdentifier);

  void disposeOfDependencyInstance(String dependencyInstanceIdentifier) =>
      _dispose(dependencyInstanceIdentifier);
}

abstract class StatelessWidgetWith<TDependency> extends StatelessWidget
    with DependencyResolver<TDependency> {
  final String _dependencyInstanceIdentifier;

  StatelessWidgetWith([this._dependencyInstanceIdentifier]);

  @override
  Widget build(BuildContext context) {
    return buildWith(context, resolve(_dependencyInstanceIdentifier));
  }

  Widget buildWith(BuildContext context, TDependency service);
}

abstract class StatelessWidgetWith2<TDependency1, TDependency2>
    extends StatelessWidget
    with DependencyResolver2<TDependency1, TDependency2> {
  final String _dependencyInstanceIdentifier1;
  final String _dependencyInstanceIdentifier2;

  StatelessWidgetWith2([
    this._dependencyInstanceIdentifier1,
    this._dependencyInstanceIdentifier2,
  ]);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      resolve1(_dependencyInstanceIdentifier1),
      resolve2(_dependencyInstanceIdentifier2),
    );
  }

  Widget buildWith(
    BuildContext context,
    TDependency1 service1,
    TDependency2 service2,
  );
}

abstract class StatelessWidgetWith3<TDependency1, TDependency2, TDependency3>
    extends StatelessWidget
    with DependencyResolver3<TDependency1, TDependency2, TDependency3> {
  final String _dependencyInstanceIdentifier1;
  final String _dependencyInstanceIdentifier2;
  final String _dependencyInstanceIdentifier3;

  StatelessWidgetWith3([
    this._dependencyInstanceIdentifier1,
    this._dependencyInstanceIdentifier2,
    this._dependencyInstanceIdentifier3,
  ]);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      resolve1(_dependencyInstanceIdentifier1),
      resolve2(_dependencyInstanceIdentifier2),
      resolve3(_dependencyInstanceIdentifier3),
    );
  }

  Widget buildWith(
    BuildContext context,
    TDependency1 service1,
    TDependency2 service2,
    TDependency3 service3,
  );
}

abstract class StatelessWidgetWith4<TDependency1, TDependency2, TDependency3,
        TDependency4> extends StatelessWidget
    with
        DependencyResolver4<TDependency1, TDependency2, TDependency3,
            TDependency4> {
  final String _dependencyInstanceIdentifier1;
  final String _dependencyInstanceIdentifier2;
  final String _dependencyInstanceIdentifier3;
  final String _dependencyInstanceIdentifier4;

  StatelessWidgetWith4([
    this._dependencyInstanceIdentifier1,
    this._dependencyInstanceIdentifier2,
    this._dependencyInstanceIdentifier3,
    this._dependencyInstanceIdentifier4,
  ]);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      resolve1(_dependencyInstanceIdentifier1),
      resolve2(_dependencyInstanceIdentifier2),
      resolve3(_dependencyInstanceIdentifier3),
      resolve4(_dependencyInstanceIdentifier4),
    );
  }

  Widget buildWith(
    BuildContext context,
    TDependency1 service1,
    TDependency2 service2,
    TDependency3 service3,
    TDependency4 service4,
  );
}

abstract class StatelessWidgetWith5<TDependency1, TDependency2, TDependency3,
        TDependency4, TDependency5> extends StatelessWidget
    with
        DependencyResolver5<TDependency1, TDependency2, TDependency3,
            TDependency4, TDependency5> {
  final String _dependencyInstanceIdentifier1;
  final String _dependencyInstanceIdentifier2;
  final String _dependencyInstanceIdentifier3;
  final String _dependencyInstanceIdentifier4;
  final String _dependencyInstanceIdentifier5;

  StatelessWidgetWith5([
    this._dependencyInstanceIdentifier1,
    this._dependencyInstanceIdentifier2,
    this._dependencyInstanceIdentifier3,
    this._dependencyInstanceIdentifier4,
    this._dependencyInstanceIdentifier5,
  ]);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      resolve1(_dependencyInstanceIdentifier1),
      resolve2(_dependencyInstanceIdentifier2),
      resolve3(_dependencyInstanceIdentifier3),
      resolve4(_dependencyInstanceIdentifier4),
      resolve5(_dependencyInstanceIdentifier5),
    );
  }

  Widget buildWith(
    BuildContext context,
    TDependency1 service1,
    TDependency2 service2,
    TDependency3 service3,
    TDependency4 service4,
    TDependency5 service5,
  );
}

abstract class StatelessWidgetWith6<TDependency1, TDependency2, TDependency3,
        TDependency4, TDependency5, TDependency6> extends StatelessWidget
    with
        DependencyResolver6<TDependency1, TDependency2, TDependency3,
            TDependency4, TDependency5, TDependency6> {
  final String _dependencyInstanceIdentifier1;
  final String _dependencyInstanceIdentifier2;
  final String _dependencyInstanceIdentifier3;
  final String _dependencyInstanceIdentifier4;
  final String _dependencyInstanceIdentifier5;
  final String _dependencyInstanceIdentifier6;

  StatelessWidgetWith6([
    this._dependencyInstanceIdentifier1,
    this._dependencyInstanceIdentifier2,
    this._dependencyInstanceIdentifier3,
    this._dependencyInstanceIdentifier4,
    this._dependencyInstanceIdentifier5,
    this._dependencyInstanceIdentifier6,
  ]);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      resolve1(_dependencyInstanceIdentifier1),
      resolve2(_dependencyInstanceIdentifier2),
      resolve3(_dependencyInstanceIdentifier3),
      resolve4(_dependencyInstanceIdentifier4),
      resolve5(_dependencyInstanceIdentifier5),
      resolve6(_dependencyInstanceIdentifier6),
    );
  }

  Widget buildWith(
    BuildContext context,
    TDependency1 service1,
    TDependency2 service2,
    TDependency3 service3,
    TDependency4 service4,
    TDependency5 service5,
    TDependency6 service6,
  );
}

abstract class StatelessWidgetWith7<
        TDependency1,
        TDependency2,
        TDependency3,
        TDependency4,
        TDependency5,
        TDependency6,
        TDependency7> extends StatelessWidget
    with
        DependencyResolver7<TDependency1, TDependency2, TDependency3,
            TDependency4, TDependency5, TDependency6, TDependency7> {
  final String _dependencyInstanceIdentifier1;
  final String _dependencyInstanceIdentifier2;
  final String _dependencyInstanceIdentifier3;
  final String _dependencyInstanceIdentifier4;
  final String _dependencyInstanceIdentifier5;
  final String _dependencyInstanceIdentifier6;
  final String _dependencyInstanceIdentifier7;

  StatelessWidgetWith7([
    this._dependencyInstanceIdentifier1,
    this._dependencyInstanceIdentifier2,
    this._dependencyInstanceIdentifier3,
    this._dependencyInstanceIdentifier4,
    this._dependencyInstanceIdentifier5,
    this._dependencyInstanceIdentifier6,
    this._dependencyInstanceIdentifier7,
  ]);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      resolve1(_dependencyInstanceIdentifier1),
      resolve2(_dependencyInstanceIdentifier2),
      resolve3(_dependencyInstanceIdentifier3),
      resolve4(_dependencyInstanceIdentifier4),
      resolve5(_dependencyInstanceIdentifier5),
      resolve6(_dependencyInstanceIdentifier6),
      resolve7(_dependencyInstanceIdentifier7),
    );
  }

  Widget buildWith(
    BuildContext context,
    TDependency1 service1,
    TDependency2 service2,
    TDependency3 service3,
    TDependency4 service4,
    TDependency5 service5,
    TDependency6 service6,
    TDependency7 service7,
  );
}
