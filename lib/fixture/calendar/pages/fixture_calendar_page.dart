import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../livescore/pages/fixture_livescore_page.dart';
import '../../common/models/vm/team_vm.dart';
import '../bloc/fixture_calendar_actions.dart';
import '../bloc/fixture_calendar_bloc.dart';
import '../bloc/fixture_calendar_states.dart';
import '../../common/models/vm/fixture_summary_vm.dart';
import '../../../general/extensions/kiwi_extension.dart';
import '../../../general/widgets/app_drawer.dart';

class FixtureCalendarPage extends StatefulWidget
    with DependencyResolver<FixtureCalendarBloc> {
  static const String routeName = '/fixture/calendar';

  @override
  _FixtureCalendarPageState createState() =>
      _FixtureCalendarPageState(resolve());
}

class _FixtureCalendarPageState extends State<FixtureCalendarPage> {
  final FixtureCalendarBloc _fixtureCalendarBloc;

  int _currentPage = 1000000000;
  PageController _pageController;

  _FixtureCalendarPageState(this._fixtureCalendarBloc);

  @override
  void initState() {
    super.initState();
    _fixtureCalendarBloc.dispatchAction(LoadFixtures(page: _currentPage));
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTeamLogoAndName(TeamVm team) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24,
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              child: Image.network(
                team.logoUrl,
                fit: BoxFit.scaleDown,
              ),
            ),
            SizedBox(height: 12),
            AutoSizeText(
              team.name,
              style: GoogleFonts.exo2(
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
              textAlign: TextAlign.center,
              maxLines: team.name.split(' ').length == 1 ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchStatus(FixtureSummaryVm fixture) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        fixture.isPostponed || fixture.isPaused
            ? fixture.status
            : fixture.isLive
                ? 'LIVE'
                : fixture.isCompleted
                    ? fixture.completedStatus
                    : '',
        style: GoogleFonts.lexendMega(
          textStyle: TextStyle(
            fontSize: 16,
            color: fixture.isLive
                ? Colors.red[400]
                : fixture.isPostponed
                    ? Colors.deepPurple[400]
                    : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1d4e89),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1d4e89),
        title: Text(
          'The 12th Player',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
        brightness: Brightness.dark,
        centerTitle: true,
        elevation: 0,
      ),
      drawer: AppDrawer(),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) => _fixtureCalendarBloc.dispatchAction(
          LoadFixtures(page: page),
        ),
        itemBuilder: (context, index) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 4.0,
                    bottom: 24.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.linear,
                          );
                        },
                      ),
                      StreamBuilder<FixtureCalendarState>(
                        initialData: FixtureCalendarLoading(),
                        stream: _fixtureCalendarBloc.state$,
                        builder: (context, snapshot) {
                          var state = snapshot.data;
                          if (state is FixtureCalendarLoading ||
                              state is FixtureCalendarError) {
                            return CircularProgressIndicator();
                          }

                          var fixtureCalendar =
                              (state as FixtureCalendarReady).fixtureCalendar;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                fixtureCalendar.year,
                                style: GoogleFonts.lexendMega(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                fixtureCalendar.month,
                                style: GoogleFonts.lexendMega(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.linear,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              StreamBuilder<FixtureCalendarState>(
                initialData: FixtureCalendarLoading(),
                stream: _fixtureCalendarBloc.state$,
                builder: (context, snapshot) {
                  var state = snapshot.data;
                  if (state is FixtureCalendarLoading) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is FixtureCalendarError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(state.message),
                      ),
                    );
                  }

                  var fixtures =
                      (state as FixtureCalendarReady).fixtureCalendar.fixtures;

                  return SliverFixedExtentList(
                    itemExtent: 250,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        var fixture = fixtures[index];

                        return Stack(
                          children: [
                            Positioned(
                              top: 20,
                              bottom: 30,
                              left: 40,
                              right: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              bottom: 40,
                              left: 30,
                              right: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              bottom: 50,
                              left: 20,
                              right: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildTeamLogoAndName(
                                            fixture.homeTeam,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  DateFormat(
                                                    'EEE, d MMM h:mm a',
                                                  ).format(fixture.startTime),
                                                  style: GoogleFonts.teko(
                                                    textStyle: TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 6),
                                                Text(
                                                  fixture.scoreString,
                                                  style: GoogleFonts.lexendMega(
                                                    textStyle: TextStyle(
                                                      fontSize: 26,
                                                    ),
                                                  ),
                                                ),
                                                if (!fixture.isUpcoming ||
                                                    fixture.isPostponed)
                                                  _buildMatchStatus(fixture),
                                              ],
                                            ),
                                          ),
                                          _buildTeamLogoAndName(
                                            fixture.awayTeam,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 14),
                                    Container(
                                      width: double.infinity,
                                      height: 1,
                                      color: Colors.black12,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 40,
                                          right: 30,
                                        ),
                                        child: Row(
                                          children: [
                                            if (fixture.league.logoUrl != null)
                                              Container(
                                                width: 35,
                                                height: 35,
                                                margin: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                child: Image.network(
                                                  fixture.league.logoUrl,
                                                  fit: BoxFit.scaleDown,
                                                ),
                                              ),
                                            if (fixture.league.name != null)
                                              Text(
                                                fixture.league.name,
                                                style: GoogleFonts.exo2(
                                                  textStyle: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            Spacer(),
                                            ElevatedButton(
                                              child: Text('Details'),
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                  FixtureLivescorePage
                                                      .routeName,
                                                  arguments: fixture,
                                                );
                                              },
                                              style: ButtonStyle(
                                                shape:
                                                    MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(16),
                                                    ),
                                                  ),
                                                ),
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                  const Color(0xff023e8a),
                                                ),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                  Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: fixtures.length,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
