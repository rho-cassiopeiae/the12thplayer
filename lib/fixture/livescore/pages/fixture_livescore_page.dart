import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../general/bloc/image_bloc.dart';
import '../widgets/discussions.dart';
import '../widgets/live_commentary_feeds.dart';
import '../widgets/match_stats.dart';
import '../widgets/performance_ratings.dart';
import '../../common/models/vm/team_vm.dart';
import '../widgets/lineups.dart';
import '../widgets/match_events.dart';
import '../widgets/submenu_icon_tile.dart';
import '../widgets/page_slider.dart';
import '../../../account/bloc/account_actions.dart';
import '../../../account/bloc/account_bloc.dart';
import '../../../account/bloc/account_states.dart';
import '../../../account/pages/auth_page.dart';
import '../../../account/pages/email_confirmation_page.dart';
import '../../common/models/vm/fixture_summary_vm.dart';
import '../bloc/fixture_livescore_actions.dart';
import '../bloc/fixture_livescore_bloc.dart';
import '../bloc/fixture_livescore_states.dart';
import '../enums/fixture_livescore_submenu.dart';
import '../enums/lineup_submenu.dart';
import '../enums/subscription_state.dart';
import '../icons/football.dart';
import '../live_commentary_feed/bloc/live_commentary_feed_bloc.dart';
import '../live_commentary_feed/enums/live_commentary_filter.dart';
import '../models/vm/fixture_full_vm.dart';
import '../widgets/sweet_sheet.dart';
import '../../../general/extensions/color_extension.dart';
import '../../../general/extensions/kiwi_extension.dart';
import '../../../account/enums/account_type.dart';

class FixtureLivescorePage extends StatefulWidget
    with
        DependencyResolver4<FixtureLivescoreBloc, LiveCommentaryFeedBloc,
            AccountBloc, ImageBloc> {
  static const String routeName = '/fixture/livescore';

  final FixtureSummaryVm fixture;

  const FixtureLivescorePage({
    Key key,
    @required this.fixture,
  }) : super(key: key);

  @override
  _FixtureLivescorePageState createState() => _FixtureLivescorePageState(
        resolve1(),
        resolve2(),
        resolve3(),
        resolve4(),
      );
}

class _FixtureLivescorePageState extends State<FixtureLivescorePage> {
  final FixtureLivescoreBloc _fixtureLivescoreBloc;
  final LiveCommentaryFeedBloc _liveCommentaryFeedBloc;
  final AccountBloc _accountBloc;
  final ImageBloc _imageBloc;

  final SweetSheet _sweetSheet = SweetSheet();

  final double _scaleWidth = 60;
  final double _scaleHeight = 60;
  final double _fabPosition = 16;
  final double _fabSize = 56;

  double _xScale;
  double _yScale;

  bool _opened;
  FixtureLivescoreSubmenu _selectedSubmenu;
  LineupSubmenu _selectedLineupSubmenu;
  LiveCommentaryFilter _selectedLiveCommentaryFilter;

  ScrollController _benchPlayersScrollController;

  SubscriptionState _subscriptionState = SubscriptionState.NotSubscribed;

  _FixtureLivescorePageState(
    this._fixtureLivescoreBloc,
    this._liveCommentaryFeedBloc,
    this._accountBloc,
    this._imageBloc,
  );

  @override
  void initState() {
    super.initState();

    _opened = false;
    _selectedSubmenu = FixtureLivescoreSubmenu.Lineups;
    _selectedLineupSubmenu = LineupSubmenu.HomeTeam;
    _selectedLiveCommentaryFilter = LiveCommentaryFilter.Top;

    _benchPlayersScrollController = ScrollController();

    var action = LoadFixture(fixtureId: widget.fixture.id);
    _fixtureLivescoreBloc.dispatchAction(action);

    action.state.then((state) {
      if (state is FixtureReady &&
          state.fixture.shouldSubscribe &&
          _subscriptionState == SubscriptionState.NotSubscribed) {
        _subscriptionState = SubscriptionState.Subscribed;
        _fixtureLivescoreBloc.dispatchAction(
          SubscribeToFixture(fixtureId: widget.fixture.id),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    _xScale = (_scaleWidth + _fabPosition * 2) * 100 / width;
    _yScale = (_scaleHeight + _fabPosition * 2) * 100 / height;
  }

  @override
  void dispose() {
    _fixtureLivescoreBloc.dispose(
      cleanupAction: _subscriptionState == SubscriptionState.Subscribed
          ? UnsubscribeFromFixture(
              fixtureId: widget.fixture.id,
            )
          : null,
    );
    _subscriptionState = SubscriptionState.Disposed;

    _liveCommentaryFeedBloc.dispose();

    _benchPlayersScrollController.dispose();

    super.dispose();
  }

  Future<bool> _showAuthDialogIfNecessary(
    String notLoggedInDesc,
    String unconfirmedDesc,
  ) async {
    var action = LoadAccount();
    _accountBloc.dispatchAction(action);

    var state = await action.state;
    if (state is AccountError) {
      return false;
    }

    var account = (state as AccountReady).account;
    if (account.type == AccountType.GuestAccount) {
      var goToAuthPage = await _sweetSheet.show<bool>(
        context: context,
        title: Text('Not logged-in'),
        description: Text(notLoggedInDesc),
        color: SweetSheetColor.WARNING,
        positive: SweetSheetAction(
          onPressed: () => Navigator.of(context).pop(true),
          title: 'SIGN-UP/IN',
          icon: Icons.login,
        ),
        negative: SweetSheetAction(
          onPressed: () => Navigator.of(context).pop(false),
          title: 'CANCEL',
        ),
      );

      if (goToAuthPage ?? false) {
        Navigator.of(context).pushNamed(
          AuthPage.routeName,
          arguments: true,
        );
      }

      return false;
    } else if (account.type == AccountType.UnconfirmedAccount) {
      var goToConfirmationPage = await _sweetSheet.show<bool>(
        context: context,
        title: Text('Unconfirmed account'),
        description: Text(unconfirmedDesc),
        color: SweetSheetColor.WARNING,
        positive: SweetSheetAction(
          onPressed: () => Navigator.of(context).pop(true),
          title: 'CONFIRM',
          icon: Icons.open_in_new_rounded,
        ),
        negative: SweetSheetAction(
          onPressed: () => Navigator.of(context).pop(false),
          title: 'CANCEL',
        ),
      );

      if (goToConfirmationPage ?? false) {
        Navigator.of(context).pushNamed(
          EmailConfirmationPage.routeName,
          arguments: true,
        );
      }

      return false;
    }

    return true;
  }

  void _toggleOpen([FixtureLivescoreSubmenu submenu]) {
    if (submenu == null) {
      setState(() {
        _opened = !_opened;
      });
    } else {
      setState(() {
        _opened = !_opened;
        _selectedSubmenu = submenu;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: HexColor.fromHex('1d3461'),
            child: Stack(
              children: <Widget>[
                Positioned(
                  bottom: _fabSize + _fabPosition * 2,
                  right: _fabPosition,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _scaleWidth),
                    child: Column(
                      children: <Widget>[
                        SubmenuIconTile(
                          iconData: Football.football_court_top_view,
                          iconSize: 36,
                          toggle: () =>
                              _toggleOpen(FixtureLivescoreSubmenu.Lineups),
                          selected: _selectedSubmenu ==
                              FixtureLivescoreSubmenu.Lineups,
                        ),
                        SizedBox(height: 20),
                        SubmenuIconTile(
                          iconData: Football.timer_clock,
                          iconSize: 32,
                          toggle: () =>
                              _toggleOpen(FixtureLivescoreSubmenu.Events),
                          selected: _selectedSubmenu ==
                              FixtureLivescoreSubmenu.Events,
                        ),
                        SizedBox(height: 20),
                        SubmenuIconTile(
                          iconData: Football.football_stats_graphic,
                          iconSize: 32,
                          toggle: () =>
                              _toggleOpen(FixtureLivescoreSubmenu.Stats),
                          selected:
                              _selectedSubmenu == FixtureLivescoreSubmenu.Stats,
                        ),
                        SizedBox(height: 20),
                        SubmenuIconTile(
                          iconData: Football.noun_commentator_3742876,
                          iconSize: 40,
                          toggle: () => _toggleOpen(
                            FixtureLivescoreSubmenu.LiveCommentaryFeeds,
                          ),
                          selected: _selectedSubmenu ==
                              FixtureLivescoreSubmenu.LiveCommentaryFeeds,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: _scaleWidth + _fabPosition * 2,
                  bottom: _fabPosition,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: _scaleHeight),
                    child: Row(
                      children: [
                        SubmenuIconTile(
                          iconData: Icons.forum,
                          iconSize: 32,
                          toggle: () =>
                              _toggleOpen(FixtureLivescoreSubmenu.Discussions),
                          selected: _selectedSubmenu ==
                              FixtureLivescoreSubmenu.Discussions,
                        ),
                        SizedBox(width: 20),
                        SubmenuIconTile(
                          iconData: Football.sports_badge_recognition,
                          iconSize: 32,
                          toggle: () => _toggleOpen(
                            FixtureLivescoreSubmenu.PerformanceRatings,
                          ),
                          selected: _selectedSubmenu ==
                              FixtureLivescoreSubmenu.PerformanceRatings,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          PageSlider(
            opened: _opened,
            xScale: _xScale,
            yScale: _yScale,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 30,
                        offset: Offset(4, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: StreamBuilder<FixtureLivescoreState>(
                    initialData: FixtureLoading(),
                    stream: _fixtureLivescoreBloc.state$,
                    builder: (context, snapshot) {
                      var state = snapshot.data;
                      if (state is FixtureLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is FixtureError) {
                        return Center(child: Text(state.message));
                      }

                      var fixture = (state as FixtureReady).fixture;

                      return CustomScrollView(
                        slivers: [
                          _buildAppBar(),
                          _buildHeader(fixture, theme),
                          ..._buildBody(fixture, theme),
                        ],
                      );
                    },
                  ),
                ),
                if (_opened)
                  GestureDetector(
                    onTap: _toggleOpen,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.menu,
        ),
        onPressed: _toggleOpen,
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
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
      pinned: true,
      elevation: 0,
      leading: IconButton(
        padding: const EdgeInsets.only(bottom: 4.0),
        icon: Icon(Icons.arrow_back_ios_rounded),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildTeamLogoAndName(TeamVm team) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            child: Image.network(
              team.logoUrl,
              fit: BoxFit.scaleDown,
            ),
          ),
          SizedBox(height: 16),
          AutoSizeText(
            team.name,
            style: GoogleFonts.exo2(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            textAlign: TextAlign.center,
            maxLines: team.name.split(' ').length == 1 ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(FixtureFullVm fixture, ThemeData theme) {
    var statusStyle = GoogleFonts.teko(
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
      ),
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              color: theme.primaryColorDark.withOpacity(0.5),
              child: Text(
                fixture.league.name?.toUpperCase() ?? 'MATCH',
                style: GoogleFonts.lexendMega(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeamLogoAndName(fixture.homeTeam),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        if (fixture.isLiveInPlay)
                          Text(
                            fixture.minuteString,
                            style: statusStyle,
                          ),
                        if (fixture.isLivePenShootout)
                          Text(
                            'PEN LIVE',
                            style: statusStyle,
                          ),
                        if (fixture.isUpcoming ||
                            fixture.isPaused ||
                            fixture.isLiveOnBreak)
                          Text(
                            fixture.status,
                            style: statusStyle,
                          ),
                        if (fixture.isCompleted)
                          Text(
                            fixture.completedStatus,
                            style: statusStyle,
                          ),
                        Text(
                          fixture.scoreString,
                          style: GoogleFonts.lexendMega(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTeamLogoAndName(fixture.awayTeam),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(FixtureFullVm fixture, ThemeData theme) {
    // @@NOTE: Since every case must return a list of widgets, we can't extract
    // the code into separate 'real' widgets. So instead we create a bunch of
    // pseudo-widgets, which really are just simple dart classes, build methods
    // of which return a list of widgets.

    switch (_selectedSubmenu) {
      case FixtureLivescoreSubmenu.Lineups:
        return Lineups(
          fixture: fixture,
          theme: theme,
          selectedLineupSubmenu: _selectedLineupSubmenu,
          benchPlayersScrollController: _benchPlayersScrollController,
        ).build(
          context: context,
          onChangeLineupSubmenu: (submenu) => setState(
            () {
              _selectedLineupSubmenu = submenu;
            },
          ),
        );
      case FixtureLivescoreSubmenu.Events:
        return MatchEvents(
          fixture: fixture,
          theme: theme,
        ).build();
      case FixtureLivescoreSubmenu.Stats:
        return MatchStats(
          fixture: fixture,
          theme: theme,
        ).build();
      case FixtureLivescoreSubmenu.Discussions:
        return Discussions(
          fixture: fixture,
          theme: theme,
        ).build(context: context);
      case FixtureLivescoreSubmenu.LiveCommentaryFeeds:
        return LiveCommentaryFeeds(
          fixture: fixture,
          theme: theme,
          selectedLiveCommentaryFilter: _selectedLiveCommentaryFilter,
          liveCommentaryFeedBloc: _liveCommentaryFeedBloc,
          imageBloc: _imageBloc,
        ).build(
          context: context,
          onChangeLiveCommentaryFilter: (filter) {
            _selectedLiveCommentaryFilter = filter;
          },
          onProtectedActionInvoked: (notLoggedInDesc, unconfirmedDesc) =>
              _showAuthDialogIfNecessary(notLoggedInDesc, unconfirmedDesc),
        );
      case FixtureLivescoreSubmenu.PerformanceRatings:
        return PerformanceRatings(
          fixture: fixture,
          theme: theme,
          fixtureLivescoreBloc: _fixtureLivescoreBloc,
        ).build();
    }

    return [];
  }
}
