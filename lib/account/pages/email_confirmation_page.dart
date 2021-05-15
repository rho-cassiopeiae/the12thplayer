import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../fixture/calendar/pages/fixture_calendar_page.dart';
import '../bloc/account_actions.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_states.dart';
import '../../general/extensions/color_extension.dart';
import '../../general/extensions/kiwi_extension.dart';
import '../../general/widgets/app_drawer.dart';

// @@NOTE: We mutate data but don't actually need to rerender, so using stateful widget is not necessary.
// ignore: must_be_immutable
class EmailConfirmationPage extends StatelessWidgetInjected<AccountBloc> {
  static const routeName = '/account/confirm-email';

  final bool goBackAfterConfirm;

  String _confirmationCode;

  EmailConfirmationPage({@required this.goBackAfterConfirm});

  @override
  Widget buildInjected(BuildContext context, AccountBloc accountBloc) {
    return Scaffold(
      backgroundColor: HexColor.fromHex('023e8a'),
      appBar: AppBar(
        backgroundColor: HexColor.fromHex('023e8a'),
        title: Text(
          'The 12th Player',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: !goBackAfterConfirm ? AppDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirmation Code',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _confirmationCode = value,
            ),
            Builder(
              builder: (context) => ElevatedButton(
                child: Text('Confirm'),
                onPressed: () async {
                  var action = ConfirmEmail(
                    confirmationCode: _confirmationCode,
                  );
                  accountBloc.dispatchAction(action);

                  var state = await action.state;
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  } else {
                    if (goBackAfterConfirm) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed(
                        FixtureCalendarPage.routeName,
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
