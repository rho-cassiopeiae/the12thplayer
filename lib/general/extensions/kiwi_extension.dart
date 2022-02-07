import 'package:flutter/src/widgets/framework.dart';
import 'package:kiwi/kiwi.dart';

final Map<String, dynamic> _identifierToInstance = {};

TDependency _resolveDependency<TDependency>(
  String dependencyInstanceIdentifier,
) {
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

void disposeOfDependencyInstance(String dependencyInstanceIdentifier) {
  _identifierToInstance.remove(dependencyInstanceIdentifier);
}

abstract class StatelessWidgetWith<TDependency> extends StatelessWidget {
  final String dependencyInstanceIdentifier;

  const StatelessWidgetWith({
    Key key,
    this.dependencyInstanceIdentifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      _resolveDependency<TDependency>(dependencyInstanceIdentifier),
    );
  }

  Widget buildWith(BuildContext context, TDependency service);
}

abstract class StatelessWidgetWith2<TDependency1, TDependency2>
    extends StatelessWidget {
  final String dependencyInstanceIdentifier1;
  final String dependencyInstanceIdentifier2;

  const StatelessWidgetWith2({
    Key key,
    this.dependencyInstanceIdentifier1,
    this.dependencyInstanceIdentifier2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1),
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2),
    );
  }

  Widget buildWith(
    BuildContext context,
    TDependency1 service1,
    TDependency2 service2,
  );
}

abstract class StatelessWidgetWith3<TDependency1, TDependency2, TDependency3>
    extends StatelessWidget {
  final String dependencyInstanceIdentifier1;
  final String dependencyInstanceIdentifier2;
  final String dependencyInstanceIdentifier3;

  const StatelessWidgetWith3({
    Key key,
    this.dependencyInstanceIdentifier1,
    this.dependencyInstanceIdentifier2,
    this.dependencyInstanceIdentifier3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1),
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2),
      _resolveDependency<TDependency3>(dependencyInstanceIdentifier3),
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
    TDependency4> extends StatelessWidget {
  final String dependencyInstanceIdentifier1;
  final String dependencyInstanceIdentifier2;
  final String dependencyInstanceIdentifier3;
  final String dependencyInstanceIdentifier4;

  const StatelessWidgetWith4({
    Key key,
    this.dependencyInstanceIdentifier1,
    this.dependencyInstanceIdentifier2,
    this.dependencyInstanceIdentifier3,
    this.dependencyInstanceIdentifier4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1),
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2),
      _resolveDependency<TDependency3>(dependencyInstanceIdentifier3),
      _resolveDependency<TDependency4>(dependencyInstanceIdentifier4),
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
    TDependency4, TDependency5> extends StatelessWidget {
  final String dependencyInstanceIdentifier1;
  final String dependencyInstanceIdentifier2;
  final String dependencyInstanceIdentifier3;
  final String dependencyInstanceIdentifier4;
  final String dependencyInstanceIdentifier5;

  const StatelessWidgetWith5({
    Key key,
    this.dependencyInstanceIdentifier1,
    this.dependencyInstanceIdentifier2,
    this.dependencyInstanceIdentifier3,
    this.dependencyInstanceIdentifier4,
    this.dependencyInstanceIdentifier5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1),
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2),
      _resolveDependency<TDependency3>(dependencyInstanceIdentifier3),
      _resolveDependency<TDependency4>(dependencyInstanceIdentifier4),
      _resolveDependency<TDependency5>(dependencyInstanceIdentifier5),
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
    TDependency4, TDependency5, TDependency6> extends StatelessWidget {
  final String dependencyInstanceIdentifier1;
  final String dependencyInstanceIdentifier2;
  final String dependencyInstanceIdentifier3;
  final String dependencyInstanceIdentifier4;
  final String dependencyInstanceIdentifier5;
  final String dependencyInstanceIdentifier6;

  const StatelessWidgetWith6({
    Key key,
    this.dependencyInstanceIdentifier1,
    this.dependencyInstanceIdentifier2,
    this.dependencyInstanceIdentifier3,
    this.dependencyInstanceIdentifier4,
    this.dependencyInstanceIdentifier5,
    this.dependencyInstanceIdentifier6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1),
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2),
      _resolveDependency<TDependency3>(dependencyInstanceIdentifier3),
      _resolveDependency<TDependency4>(dependencyInstanceIdentifier4),
      _resolveDependency<TDependency5>(dependencyInstanceIdentifier5),
      _resolveDependency<TDependency6>(dependencyInstanceIdentifier6),
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
    TDependency7> extends StatelessWidget {
  final String dependencyInstanceIdentifier1;
  final String dependencyInstanceIdentifier2;
  final String dependencyInstanceIdentifier3;
  final String dependencyInstanceIdentifier4;
  final String dependencyInstanceIdentifier5;
  final String dependencyInstanceIdentifier6;
  final String dependencyInstanceIdentifier7;

  const StatelessWidgetWith7({
    Key key,
    this.dependencyInstanceIdentifier1,
    this.dependencyInstanceIdentifier2,
    this.dependencyInstanceIdentifier3,
    this.dependencyInstanceIdentifier4,
    this.dependencyInstanceIdentifier5,
    this.dependencyInstanceIdentifier6,
    this.dependencyInstanceIdentifier7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildWith(
      context,
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1),
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2),
      _resolveDependency<TDependency3>(dependencyInstanceIdentifier3),
      _resolveDependency<TDependency4>(dependencyInstanceIdentifier4),
      _resolveDependency<TDependency5>(dependencyInstanceIdentifier5),
      _resolveDependency<TDependency6>(dependencyInstanceIdentifier6),
      _resolveDependency<TDependency7>(dependencyInstanceIdentifier7),
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

abstract class StateWith<TWidget extends StatefulWidget, TDependency>
    extends State<TWidget> {
  String get dependencyInstanceIdentifier => null;

  TDependency _service;
  TDependency get service => _service ??=
      _resolveDependency<TDependency>(dependencyInstanceIdentifier);
}

abstract class StateWith2<TWidget extends StatefulWidget, TDependency1,
    TDependency2> extends State<TWidget> {
  String get dependencyInstanceIdentifier1 => null;
  String get dependencyInstanceIdentifier2 => null;

  TDependency1 _service1;
  TDependency1 get service1 => _service1 ??=
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1);

  TDependency2 _service2;
  TDependency2 get service2 => _service2 ??=
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2);
}

abstract class StateWith3<TWidget extends StatefulWidget, TDependency1,
    TDependency2, TDependency3> extends State<TWidget> {
  String get dependencyInstanceIdentifier1 => null;
  String get dependencyInstanceIdentifier2 => null;
  String get dependencyInstanceIdentifier3 => null;

  TDependency1 _service1;
  TDependency1 get service1 => _service1 ??=
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1);

  TDependency2 _service2;
  TDependency2 get service2 => _service2 ??=
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2);

  TDependency3 _service3;
  TDependency3 get service3 => _service3 ??=
      _resolveDependency<TDependency3>(dependencyInstanceIdentifier3);
}

abstract class StateWith4<TWidget extends StatefulWidget, TDependency1,
    TDependency2, TDependency3, TDependency4> extends State<TWidget> {
  String get dependencyInstanceIdentifier1 => null;
  String get dependencyInstanceIdentifier2 => null;
  String get dependencyInstanceIdentifier3 => null;
  String get dependencyInstanceIdentifier4 => null;

  TDependency1 _service1;
  TDependency1 get service1 => _service1 ??=
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1);

  TDependency2 _service2;
  TDependency2 get service2 => _service2 ??=
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2);

  TDependency3 _service3;
  TDependency3 get service3 => _service3 ??=
      _resolveDependency<TDependency3>(dependencyInstanceIdentifier3);

  TDependency4 _service4;
  TDependency4 get service4 => _service4 ??=
      _resolveDependency<TDependency4>(dependencyInstanceIdentifier4);
}

abstract class StateWith5<
    TWidget extends StatefulWidget,
    TDependency1,
    TDependency2,
    TDependency3,
    TDependency4,
    TDependency5> extends State<TWidget> {
  String get dependencyInstanceIdentifier1 => null;
  String get dependencyInstanceIdentifier2 => null;
  String get dependencyInstanceIdentifier3 => null;
  String get dependencyInstanceIdentifier4 => null;
  String get dependencyInstanceIdentifier5 => null;

  TDependency1 _service1;
  TDependency1 get service1 => _service1 ??=
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1);

  TDependency2 _service2;
  TDependency2 get service2 => _service2 ??=
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2);

  TDependency3 _service3;
  TDependency3 get service3 => _service3 ??=
      _resolveDependency<TDependency3>(dependencyInstanceIdentifier3);

  TDependency4 _service4;
  TDependency4 get service4 => _service4 ??=
      _resolveDependency<TDependency4>(dependencyInstanceIdentifier4);

  TDependency5 _service5;
  TDependency5 get service5 => _service5 ??=
      _resolveDependency<TDependency5>(dependencyInstanceIdentifier5);
}

abstract class StateWith6<
    TWidget extends StatefulWidget,
    TDependency1,
    TDependency2,
    TDependency3,
    TDependency4,
    TDependency5,
    TDependency6> extends State<TWidget> {
  String get dependencyInstanceIdentifier1 => null;
  String get dependencyInstanceIdentifier2 => null;
  String get dependencyInstanceIdentifier3 => null;
  String get dependencyInstanceIdentifier4 => null;
  String get dependencyInstanceIdentifier5 => null;
  String get dependencyInstanceIdentifier6 => null;

  TDependency1 _service1;
  TDependency1 get service1 => _service1 ??=
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1);

  TDependency2 _service2;
  TDependency2 get service2 => _service2 ??=
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2);

  TDependency3 _service3;
  TDependency3 get service3 => _service3 ??=
      _resolveDependency<TDependency3>(dependencyInstanceIdentifier3);

  TDependency4 _service4;
  TDependency4 get service4 => _service4 ??=
      _resolveDependency<TDependency4>(dependencyInstanceIdentifier4);

  TDependency5 _service5;
  TDependency5 get service5 => _service5 ??=
      _resolveDependency<TDependency5>(dependencyInstanceIdentifier5);

  TDependency6 _service6;
  TDependency6 get service6 => _service6 ??=
      _resolveDependency<TDependency6>(dependencyInstanceIdentifier6);
}

abstract class StateWith7<
    TWidget extends StatefulWidget,
    TDependency1,
    TDependency2,
    TDependency3,
    TDependency4,
    TDependency5,
    TDependency6,
    TDependency7> extends State<TWidget> {
  String get dependencyInstanceIdentifier1 => null;
  String get dependencyInstanceIdentifier2 => null;
  String get dependencyInstanceIdentifier3 => null;
  String get dependencyInstanceIdentifier4 => null;
  String get dependencyInstanceIdentifier5 => null;
  String get dependencyInstanceIdentifier6 => null;
  String get dependencyInstanceIdentifier7 => null;

  TDependency1 _service1;
  TDependency1 get service1 => _service1 ??=
      _resolveDependency<TDependency1>(dependencyInstanceIdentifier1);

  TDependency2 _service2;
  TDependency2 get service2 => _service2 ??=
      _resolveDependency<TDependency2>(dependencyInstanceIdentifier2);

  TDependency3 _service3;
  TDependency3 get service3 => _service3 ??=
      _resolveDependency<TDependency3>(dependencyInstanceIdentifier3);

  TDependency4 _service4;
  TDependency4 get service4 => _service4 ??=
      _resolveDependency<TDependency4>(dependencyInstanceIdentifier4);

  TDependency5 _service5;
  TDependency5 get service5 => _service5 ??=
      _resolveDependency<TDependency5>(dependencyInstanceIdentifier5);

  TDependency6 _service6;
  TDependency6 get service6 => _service6 ??=
      _resolveDependency<TDependency6>(dependencyInstanceIdentifier6);

  TDependency7 _service7;
  TDependency7 get service7 => _service7 ??=
      _resolveDependency<TDependency7>(dependencyInstanceIdentifier7);
}
