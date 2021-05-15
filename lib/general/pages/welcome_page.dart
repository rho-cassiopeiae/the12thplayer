import 'package:flutter/material.dart';

import '../../account/bloc/account_actions.dart';
import '../../account/bloc/account_bloc.dart';
import '../../account/bloc/account_states.dart';
import '../../fixture/calendar/pages/fixture_calendar_page.dart';
import '../extensions/kiwi_extension.dart';

class WelcomePage extends StatefulWidget with DependencyResolver<AccountBloc> {
  @override
  _WelcomePageState createState() => _WelcomePageState(resolve());
}

class _WelcomePageState extends State<WelcomePage> {
  final AccountBloc _accountBloc;

  _WelcomePageState(this._accountBloc);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var action = LoadAccount();
    _accountBloc.dispatchAction(action);

    action.state.then((state) {
      if (state is AccountReady) {
        Navigator.of(context).pushReplacementNamed(
          FixtureCalendarPage.routeName,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
    );
  }
}
