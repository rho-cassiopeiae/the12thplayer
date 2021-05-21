import 'package:awesome_notifications/awesome_notifications.dart';
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
  void initState() {
    super.initState();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        await _requestUserPermission();
      }

      var action = LoadAccount();
      _accountBloc.dispatchAction(action);

      var state = await action.state;
      if (state is AccountReady) {
        Navigator.of(context).pushReplacementNamed(
          FixtureCalendarPage.routeName,
        );
      }
    });
  }

  Future _requestUserPermission() {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xfffbfbfb),
        title: Text(
          'Notifications',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/animated-bell.gif',
              height: 200,
              fit: BoxFit.fitWidth,
            ),
            Text(
              'Allow The12thPlayer to send notifications',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Later',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await AwesomeNotifications()
                  .requestPermissionToSendNotifications();
            },
            child: Text(
              'Allow',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF398AE5),
    );
  }
}
