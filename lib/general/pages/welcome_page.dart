import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../team/bloc/team_actions.dart';
import '../../team/bloc/team_bloc.dart';
import '../../team/bloc/team_states.dart';
import '../../account/bloc/account_actions.dart';
import '../../account/bloc/account_bloc.dart';
import '../../account/bloc/account_states.dart';
import '../../fixture/calendar/pages/fixture_calendar_page.dart';
import '../extensions/kiwi_extension.dart';

class WelcomePage extends StatefulWidget
    with DependencyResolver2<AccountBloc, TeamBloc> {
  @override
  _WelcomePageState createState() => _WelcomePageState(resolve1(), resolve2());
}

class _WelcomePageState extends State<WelcomePage> {
  final AccountBloc _accountBloc;
  final TeamBloc _teamBloc;

  ScrollController _scrollController;
  bool _showTeamSelection;

  _WelcomePageState(this._accountBloc, this._teamBloc);

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _showTeamSelection = false;

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        await _requestUserPermission();
      }

      var action = LoadAccount();
      _accountBloc.dispatchAction(action);

      var state = await action.state;
      if (state is AccountReady) {
        var action = CheckSomeTeamSelected();
        _teamBloc.dispatchAction(action);

        var state = await action.state;
        if (state.selected) {
          Navigator.of(context).pushReplacementNamed(
            FixtureCalendarPage.routeName,
          );
        } else {
          _teamBloc.dispatchAction(LoadTeamsWithCommunities());
          setState(() {
            _showTeamSelection = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      color: const Color(0xFF273469),
      child: _showTeamSelection
          ? StreamBuilder<TeamsWithCommunitiesState>(
              initialData: TeamsWithCommunitiesLoading(),
              stream: _teamBloc.teamsWithCommunitiesState$,
              builder: (context, snapshot) {
                var state = snapshot.data;
                if (state is TeamsWithCommunitiesLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is TeamsWithCommunitiesError) {
                  return Center(child: Text(state.message));
                }

                var teams = (state as TeamsWithCommunitiesReady).teams;
                return Center(
                  child: Card(
                    elevation: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 48),
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white54,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FadingEdgeScrollView.fromScrollView(
                        gradientFractionOnEnd: 0.6,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            var team = teams[index];
                            return GestureDetector(
                              onTap: () async {
                                var action = SelectTeam(
                                  teamId: team.id,
                                  teamName: team.name,
                                  teamLogoUrl: team.logoUrl,
                                );
                                _teamBloc.dispatchAction(action);

                                await action.state;

                                Navigator.of(context).pushReplacementNamed(
                                  FixtureCalendarPage.routeName,
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: 8,
                                  bottom: index == teams.length - 1 ? 28 : 8,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage:
                                          NetworkImage(team.logoUrl),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: AutoSizeText(
                                        team.name,
                                        style: GoogleFonts.bebasNeue(
                                          color: Colors.white,
                                          fontSize: 34,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: teams.length,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          : null,
    );
  }
}
