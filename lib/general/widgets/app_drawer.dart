import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../feed/pages/feed_page.dart';
import '../../account/pages/profile_page.dart';
import '../../team/pages/team_squad_page.dart';
import '../../fixture/calendar/pages/fixture_calendar_page.dart';
import '../../account/bloc/account_actions.dart';
import '../../account/bloc/account_bloc.dart';
import '../../account/bloc/account_states.dart';
import '../../account/enums/account_type.dart';
import '../../account/pages/auth_page.dart';
import '../../account/pages/email_confirmation_page.dart';
import '../extensions/kiwi_extension.dart';

class AppDrawer extends StatelessWidgetInjected<AccountBloc> {
  @override
  Widget buildInjected(BuildContext context, AccountBloc accountBloc) {
    var action = LoadAccount();
    accountBloc.dispatchAction(action);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color(0xFF1e2749),
            ),
            child: Text(
              'The 12th Player',
              style: GoogleFonts.teko(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'Squad',
              style: GoogleFonts.patuaOne(fontSize: 20),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                TeamSquadPage.routeName,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.all_inclusive_rounded),
            title: Text(
              'Fixtures',
              style: GoogleFonts.patuaOne(fontSize: 20),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                FixtureCalendarPage.routeName,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.article),
            title: Text(
              'Feed',
              style: GoogleFonts.patuaOne(fontSize: 20),
            ),
            onTap: () {
              Navigator.of(context).pop();

              String routeName;
              Navigator.of(context).popUntil((route) {
                routeName = route.settings.name;
                return true;
              });

              if (routeName != FeedPage.routeName) {
                Navigator.of(context).pushReplacementNamed(
                  FeedPage.routeName,
                );
              }
            },
          ),
          FutureBuilder<AccountState>(
            initialData: AccountLoading(),
            future: action.state,
            builder: (context, snapshot) {
              var state = snapshot.data;
              if (state is AccountLoading) {
                return ListTile(
                  title: CircularProgressIndicator(),
                );
              } else if (state is AccountError) {
                return SizedBox.shrink();
              }

              var account = (state as AccountReady).account;
              return ListTile(
                leading: Icon(Icons.account_box_rounded),
                title: Text(
                  account.type == AccountType.GuestAccount
                      ? 'Sign up/in'
                      : account.type == AccountType.UnconfirmedAccount
                          ? 'Confirm email'
                          : 'Profile',
                  style: GoogleFonts.patuaOne(fontSize: 20),
                ),
                onTap: () {
                  if (account.type == AccountType.GuestAccount) {
                    Navigator.of(context).pushReplacementNamed(
                      AuthPage.routeName,
                    );
                  } else if (account.type == AccountType.UnconfirmedAccount) {
                    Navigator.of(context).pushReplacementNamed(
                      EmailConfirmationPage.routeName,
                    );
                  } else {
                    Navigator.of(context).pushReplacementNamed(
                      ProfilePage.routeName,
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
