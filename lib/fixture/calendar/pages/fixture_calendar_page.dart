import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../livescore/pages/fixture_livescore_page.dart';
import '../../../team/models/vm/team_vm.dart';
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

    _fixtureCalendarBloc.dispatchAction(
      LoadFixtureCalendar(page: _currentPage),
    );
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
          top: 24.0,
        ),
        child: Column(
          children: [
            Container(
              width: 60.0,
              height: 60.0,
              child: Image.network(
                team.logoUrl,
                fit: BoxFit.scaleDown,
              ),
            ),
            SizedBox(height: 12.0),
            AutoSizeText(
              team.name,
              style: GoogleFonts.exo2(
                fontSize: 16.0,
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
        fixture.isCompleted || fixture.isPostponed || fixture.isPaused
            ? fixture.status
            : fixture.isLive
                ? 'LIVE'
                : '',
        style: GoogleFonts.lexendMega(
          fontSize: 16.0,
          color: fixture.isLive
              ? Colors.red[400]
              : fixture.isPostponed
                  ? Colors.deepPurple[400]
                  : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF273469),
      appBar: AppBar(
        backgroundColor: const Color(0xFF273469),
        title: Text(
          'The 12th Player',
          style: GoogleFonts.teko(
            color: Colors.white,
            fontSize: 30.0,
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
          LoadFixtureCalendar(page: page),
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
                      StreamBuilder<LoadFixtureCalendarState>(
                        initialData: FixtureCalendarLoading(),
                        stream: _fixtureCalendarBloc.fixtureCalendarState$,
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
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                fixtureCalendar.month,
                                style: GoogleFonts.lexendMega(
                                  color: Colors.white,
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
              StreamBuilder<LoadFixtureCalendarState>(
                initialData: FixtureCalendarLoading(),
                stream: _fixtureCalendarBloc.fixtureCalendarState$,
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
                              top: 20.0,
                              bottom: 30.0,
                              left: 40.0,
                              right: 40.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10.0,
                              bottom: 40.0,
                              left: 30.0,
                              right: 30.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0.0,
                              bottom: 50.0,
                              left: 20.0,
                              right: 20.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
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
                                              top: 4.0,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  DateFormat(
                                                    'EEE, d MMM h:mm a',
                                                  ).format(fixture.startTime),
                                                  style: GoogleFonts.teko(
                                                    fontSize: 20.0,
                                                  ),
                                                ),
                                                SizedBox(height: 6.0),
                                                Text(
                                                  fixture.scoreString,
                                                  style: GoogleFonts.lexendMega(
                                                    fontSize: 26.0,
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
                                    SizedBox(height: 14.0),
                                    Container(
                                      width: double.infinity,
                                      height: 1.0,
                                      color: Colors.black12,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 40.0,
                                          right: 30.0,
                                        ),
                                        child: Row(
                                          children: [
                                            if (fixture.league.logoUrl != null)
                                              Container(
                                                width: 35.0,
                                                height: 35.0,
                                                margin: const EdgeInsets.only(
                                                  right: 8.0,
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
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            Spacer(),
                                            ElevatedButton(
                                              child: Text('Fanzone'),
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
                                                      Radius.circular(16.0),
                                                    ),
                                                  ),
                                                ),
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                  const Color(0xff0466c8),
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
