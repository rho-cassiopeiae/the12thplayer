import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../fixture/calendar/pages/fixture_calendar_page.dart';
import '../../general/widgets/app_drawer.dart';
import '../bloc/account_actions.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_states.dart';
import '../enums/account_type.dart';
import '../enums/auth_page_mode.dart';
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

  final TextStyle _labelStyle = GoogleFonts.openSans(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  final BoxDecoration _decoration = BoxDecoration(
    color: const Color(0xFF6CA8F1),
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: const Offset(0, 2),
      ),
    ],
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: _labelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: _decoration,
          height: 60.0,
          child: TextField(
            onChanged: (value) => _email = value,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.openSans(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Username',
          style: _labelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: _decoration,
          height: 60.0,
          child: TextField(
            onChanged: (value) => _username = value,
            style: GoogleFonts.openSans(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.text_fields,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: _labelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: _decoration,
          height: 60.0,
          child: TextField(
            onChanged: (value) => _password = value,
            obscureText: true,
            style: GoogleFonts.openSans(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
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
            _mode == AuthPageMode.SignUp ? 'SIGN UP' : 'SIGN IN',
            style: GoogleFonts.openSans(
              color: const Color(0xFF527DAA),
              letterSpacing: 1.5,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        _mode == AuthPageMode.SignUp ? 'Sign Up' : 'Sign In',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      _buildEmailField(),
                      if (_mode == AuthPageMode.SignUp) ...[
                        SizedBox(height: 30.0),
                        _buildUsernameField(),
                      ],
                      SizedBox(height: 30.0),
                      _buildPasswordField(),
                      SizedBox(height: 30.0),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                child: IconButton(
                  icon: widget.goBackAfterAuth
                      ? Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                  onPressed: () => widget.goBackAfterAuth
                      ? Navigator.of(context).pop()
                      : _scaffoldKey.currentState.openDrawer(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.swap_horiz_rounded,
          size: 34,
          color: const Color(0xFF527DAA),
        ),
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
