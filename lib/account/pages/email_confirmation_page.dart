import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../fixture/calendar/pages/fixture_calendar_page.dart';
import '../bloc/account_actions.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_states.dart';
import '../../general/extensions/kiwi_extension.dart';
import '../../general/widgets/app_drawer.dart';

// @@NOTE: We mutate data but don't actually need to rerender, so using stateful widget is not necessary.
// ignore: must_be_immutable
class EmailConfirmationPage extends StatelessWidgetInjected<AccountBloc> {
  static const routeName = '/account/confirm-email';

  final bool goBackAfterConfirm;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _confirmationCode;

  EmailConfirmationPage({@required this.goBackAfterConfirm});

  Widget _buildOtpField(BuildContext context) {
    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        color: const Color(0xFF6CA8F1),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        backgroundColor: Colors.transparent,
        obscureText: false,
        keyboardType: TextInputType.number,
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.underline,
          activeColor: Colors.white,
          inactiveColor: Colors.white,
          selectedColor: Colors.white,
        ),
        onChanged: (value) => _confirmationCode = value,
        beforeTextPaste: (text) => true,
      ),
    );
  }

  Widget _buildSubmitButton(AccountBloc accountBloc) {
    return Container(
      width: double.infinity,
      child: Builder(
        builder: (context) => ElevatedButton(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(5.0),
            padding: MaterialStateProperty.all(const EdgeInsets.all(15.0)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(Colors.white),
          ),
          child: Text(
            'CONFIRM',
            style: GoogleFonts.openSans(
              color: const Color(0xFF527DAA),
              letterSpacing: 1.5,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
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
    );
  }

  @override
  Widget buildInjected(BuildContext context, AccountBloc accountBloc) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF73AEF5),
                      const Color(0xFF61A4F1),
                      const Color(0xFF478DE0),
                      const Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 80.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Confirm email',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      _buildOtpField(context),
                      SizedBox(height: 30.0),
                      _buildSubmitButton(accountBloc),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                child: IconButton(
                  icon: goBackAfterConfirm
                      ? Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                  onPressed: () => goBackAfterConfirm
                      ? Navigator.of(context).pop()
                      : _scaffoldKey.currentState.openDrawer(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
