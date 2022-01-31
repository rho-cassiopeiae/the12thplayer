import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../match_predictions/pages/match_predictions_page.dart';
import '../../feed/pages/feed_page.dart';
import '../../account/pages/profile_page.dart';
import '../../team/pages/team_squad_page.dart';
import '../../fixture/calendar/pages/fixture_calendar_page.dart';
import '../../account/bloc/account_actions.dart';
import '../../account/bloc/account_bloc.dart';
import '../../account/bloc/account_states.dart';
import '../../account/enums/account_type.dart';
import '../../account/pages/auth_page.dart';
import '../extensions/kiwi_extension.dart';

class AppDrawer extends StatelessWidgetWith<AccountBloc> {
  @override
  Widget buildWith(BuildContext context, AccountBloc accountBloc) {
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
                  fontSize: 30.0,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.groups_outlined),
            title: Text(
              'Squad',
              style: GoogleFonts.patuaOne(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                TeamSquadPage.routeName,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.schema_outlined),
            title: Text(
              'Fixtures',
              style: GoogleFonts.patuaOne(fontSize: 20.0),
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
              style: GoogleFonts.patuaOne(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                FeedPage.routeName,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics_outlined),
            title: Text(
              'Predictions',
              style: GoogleFonts.patuaOne(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                MatchPredictionsPage.routeName,
              );
            },
          ),
          FutureBuilder<LoadAccountState>(
            initialData: AccountLoading(),
            future: action.state,
            builder: (context, snapshot) {
              var state = snapshot.data;
              if (state is AccountLoading || state is AccountError) {
                return ListTile(
                  title: CircularProgressIndicator(),
                );
              }

              var account = (state as AccountReady).account;
              return ListTile(
                leading: Icon(Icons.account_box_rounded),
                title: Text(
                  account.type == AccountType.Guest
                      ? 'Authenticate'
                      : 'Profile',
                  style: GoogleFonts.patuaOne(fontSize: 20),
                ),
                onTap: () {
                  if (account.type == AccountType.Guest) {
                    Navigator.of(context).pushReplacementNamed(
                      AuthPage.routeName,
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
