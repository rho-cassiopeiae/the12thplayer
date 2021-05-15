import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../fixture/calendar/pages/fixture_calendar_page.dart';
import '../../general/widgets/app_drawer.dart';
import '../bloc/account_actions.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_states.dart';
import '../enums/account_type.dart';
import '../enums/auth_page_mode.dart';
import '../../general/extensions/color_extension.dart';
import '../../general/extensions/kiwi_extension.dart';
import 'email_confirmation_page.dart';

class AuthPage extends StatefulWidget with DependencyResolver<AccountBloc> {
  static const routeName = '/account/authentication';

  final bool goBackAfterAuth;

  const AuthPage({
    Key key,
    @required this.goBackAfterAuth,
  }) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState(resolve());
}

class _AuthPageState extends State<AuthPage> {
  final AccountBloc _accountBloc;

  AuthPageMode _mode;

  String _email;
  String _username;
  String _password;

  _AuthPageState(this._accountBloc);

  @override
  void initState() {
    super.initState();
    _mode = AuthPageMode.SignUp;
  }

  @override
  Widget build(BuildContext context) {
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
      drawer: !widget.goBackAfterAuth ? AppDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              onChanged: (value) => _email = value,
            ),
            if (_mode == AuthPageMode.SignUp)
              TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
                onChanged: (value) => _username = value,
              ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
              onChanged: (value) => _password = value,
            ),
            Builder(
              builder: (context) => ElevatedButton(
                child: Text(
                  _mode == AuthPageMode.SignUp ? 'Sign up' : 'Sign in',
                ),
                onPressed: () async {
                  if (_mode == AuthPageMode.SignUp) {
                    var action = SignUp(
                      email: _email,
                      username: _username,
                      password: _password,
                    );
                    _accountBloc.dispatchAction(action);

                    var state = await action.state;
                    if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    } else {
                      Navigator.of(context).pushReplacementNamed(
                        EmailConfirmationPage.routeName,
                        arguments: widget.goBackAfterAuth,
                      );
                    }
                  } else {
                    var action = SignIn(
                      email: _email,
                      password: _password,
                    );
                    _accountBloc.dispatchAction(action);

                    var state = await action.state;
                    if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    } else {
                      var account = (state as AuthSuccess).account;
                      if (account.type == AccountType.UnconfirmedAccount) {
                        Navigator.of(context).pushReplacementNamed(
                          EmailConfirmationPage.routeName,
                          arguments: widget.goBackAfterAuth,
                        );
                      } else {
                        if (widget.goBackAfterAuth) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushReplacementNamed(
                            FixtureCalendarPage.routeName,
                          );
                        }
                      }
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.swap_horizontal_circle_sharp),
        onPressed: () {
          setState(() {
            _mode = _mode == AuthPageMode.SignUp
                ? AuthPageMode.SignIn
                : AuthPageMode.SignUp;
          });
        },
      ),
    );
  }
}
