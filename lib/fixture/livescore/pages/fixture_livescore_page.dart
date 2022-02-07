import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../general/bloc/image_bloc.dart';
import '../player_rating/bloc/player_rating_bloc.dart';
import '../discussion/bloc/discussion_bloc.dart';
import '../video_reaction/bloc/video_reaction_bloc.dart';
import '../video_reaction/enums/video_reaction_filter.dart';
import '../widgets/video_reactions.dart';
import '../widgets/discussions.dart';
import '../widgets/match_stats.dart';
import '../widgets/player_ratings.dart';
import '../../../team/models/vm/team_vm.dart';
import '../widgets/lineups.dart';
import '../widgets/match_events.dart';
import '../widgets/submenu_icon_tile.dart';
import '../widgets/page_slider.dart';
import '../../../account/bloc/account_actions.dart';
import '../../../account/bloc/account_bloc.dart';
import '../../../account/bloc/account_states.dart';
import '../../../account/pages/auth_page.dart';
import '../../common/models/vm/fixture_summary_vm.dart';
import '../bloc/fixture_livescore_actions.dart';
import '../bloc/fixture_livescore_bloc.dart';
import '../bloc/fixture_livescore_states.dart';
import '../enums/fixture_livescore_submenu.dart';
import '../enums/lineup_submenu.dart';
import '../enums/subscription_state.dart';
import '../icons/football.dart';
import '../models/vm/fixture_full_vm.dart';
import '../../../general/widgets/sweet_sheet.dart';
import '../../../general/extensions/kiwi_extension.dart';
import '../../../account/enums/account_type.dart';

class FixtureLivescorePage extends StatefulWidget {
  static const String routeName = '/fixture/livescore';

  final FixtureSummaryVm fixture;

  const FixtureLivescorePage({
    Key key,
    @required this.fixture,
  }) : super(key: key);

  @override
  _FixtureLivescorePageState createState() => _FixtureLivescorePageState();
}

class _FixtureLivescorePageState extends StateWith6<
    FixtureLivescorePage,
    FixtureLivescoreBloc,
    DiscussionBloc,
    AccountBloc,
    PlayerRatingBloc,
    VideoReactionBloc,
    ImageBloc> {
  FixtureLivescoreBloc get _fixtureLivescoreBloc => service1;
  DiscussionBloc get _discussionBloc => service2;
  AccountBloc get _accountBloc => service3;
  PlayerRatingBloc get _playerRatingBloc => service4;
  VideoReactionBloc get _videoReactionBloc => service5;
  ImageBloc get _imageBloc => service6;

  Discussions _discussions;
  PlayerRatings _playerRatings;
  VideoReactions _videoReactions;

  final SweetSheet _sweetSheet = SweetSheet();

  final double _scaleWidth = 60.0;
  final double _scaleHeight = 60.0;
  final double _fabPosition = 16.0;
  final double _fabSize = 56.0;

  double _xScale;
  double _yScale;

  bool _opened;
  FixtureLivescoreSubmenu _selectedSubmenu;
  LineupSubmenu _selectedLineupSubmenu;
  VideoReactionFilter _selectedVideoReactionFilter;

  ScrollController _benchPlayersScrollController;

  SubscriptionState _subscriptionState = SubscriptionState.NotSubscribed;

  @override
  void initState() {
    super.initState();

    _opened = false;
    _selectedSubmenu = FixtureLivescoreSubmenu.Lineups;
    _selectedLineupSubmenu = LineupSubmenu.HomeTeam;
    _selectedVideoReactionFilter = VideoReactionFilter.Top;

    _benchPlayersScrollController = ScrollController();

    var action = LoadFixture(fixtureId: widget.fixture.id);
    _fixtureLivescoreBloc.dispatchAction(action);

    action.state.then((state) {
      if (state is FixtureReady &&
          state.shouldSubscribe &&
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

    _xScale = (_scaleWidth + _fabPosition * 2.0) * 100.0 / width;
    _yScale = (_scaleHeight + _fabPosition * 2.0) * 100.0 / height;
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

    _discussionBloc.dispose();

    _benchPlayersScrollController.dispose();

    super.dispose();
  }

  Future<bool> _showAuthDialogIfNecessary() async {
    var action = LoadAccount();
    _accountBloc.dispatchAction(action);

    var state = await action.state;
    if (state is AccountError) {
      return false;
    }

    var account = (state as AccountReady).account;
    if (account.type == AccountType.Guest) {
      bool goToAuthPage = await _sweetSheet.show<bool>(
        context: context,
        title: Text('Not authenticated'),
        description: Text('Authenticate to continue'),
        color: SweetSheetColor.WARNING,
        positive: SweetSheetAction(
          onPressed: () => Navigator.of(context).pop(true),
          title: 'SIGN-UP/IN/CONFIRM',
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
        if (_selectedSubmenu != submenu) {
          _selectedSubmenu = submenu;
          // ignore: missing_enum_constant_in_switch
          switch (_selectedSubmenu) {
            case FixtureLivescoreSubmenu.Discussions:
              _discussions = null;
              break;
            case FixtureLivescoreSubmenu.PlayerRatings:
              _playerRatings = null;
              break;
            case FixtureLivescoreSubmenu.VideoReactions:
              _videoReactions = null;
              break;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xff1d3461),
            child: Stack(
              children: [
                Positioned(
                  bottom: _fabSize + _fabPosition * 2,
                  right: _fabPosition,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _scaleWidth),
                    child: Column(
                      children: [
                        SubmenuIconTile(
                          iconData: Football.football_court_top_view,
                          iconSize: 36.0,
                          toggle: () =>
                              _toggleOpen(FixtureLivescoreSubmenu.Lineups),
                          selected: _selectedSubmenu ==
                              FixtureLivescoreSubmenu.Lineups,
                        ),
                        SizedBox(height: 20.0),
                        SubmenuIconTile(
                          iconData: Football.timer_clock,
                          iconSize: 32.0,
                          toggle: () =>
                              _toggleOpen(FixtureLivescoreSubmenu.Events),
                          selected: _selectedSubmenu ==
                              FixtureLivescoreSubmenu.Events,
                        ),
                        SizedBox(height: 20.0),
                        SubmenuIconTile(
                          iconData: Football.football_stats_graphic,
                          iconSize: 32.0,
                          toggle: () =>
                              _toggleOpen(FixtureLivescoreSubmenu.Stats),
                          selected:
                              _selectedSubmenu == FixtureLivescoreSubmenu.Stats,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: _scaleWidth + _fabPosition * 2.0,
                  bottom: _fabPosition,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: _scaleHeight),
                    child: Row(
                      children: [
                        SubmenuIconTile(
                          iconData: Icons.forum,
                          iconSize: 32.0,
                          toggle: () =>
                              _toggleOpen(FixtureLivescoreSubmenu.Discussions),
                          selected: _selectedSubmenu ==
                              FixtureLivescoreSubmenu.Discussions,
                        ),
                        SizedBox(width: 20.0),
                        SubmenuIconTile(
                          iconData: Football.sports_badge_recognition,
                          iconSize: 32.0,
                          toggle: () => _toggleOpen(
                            FixtureLivescoreSubmenu.PlayerRatings,
                          ),
                          selected: _selectedSubmenu ==
                              FixtureLivescoreSubmenu.PlayerRatings,
                        ),
                        SizedBox(width: 20.0),
                        SubmenuIconTile(
                          iconData: Icons.videocam,
                          iconSize: 32.0,
                          toggle: () => _toggleOpen(
                            FixtureLivescoreSubmenu.VideoReactions,
                          ),
                          selected: _selectedSubmenu ==
                              FixtureLivescoreSubmenu.VideoReactions,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 30.0,
                        offset: Offset(4.0, 4.0),
                      ),
                    ],
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                  child: StreamBuilder<LoadFixtureState>(
                    initialData: FixtureLoading(),
                    stream: _fixtureLivescoreBloc.fixtureLivescoreState$,
                    builder: (context, snapshot) {
                      var state = snapshot.data;
                      if (state is FixtureLoading) {
                        return Center(child: CircularProgressIndicator());
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
        child: Icon(Icons.menu),
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
            fontSize: 30.0,
          ),
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: true,
      pinned: true,
      elevation: 0.0,
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
            width: 75.0,
            height: 75.0,
            child: Image.network(
              team.logoUrl,
              fit: BoxFit.scaleDown,
            ),
          ),
          SizedBox(height: 16.0),
          AutoSizeText(
            team.name,
            style: GoogleFonts.exo2(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
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
        fontSize: 22.0,
      ),
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              color: theme.primaryColorDark.withOpacity(0.5),
              child: Text(
                fixture.league.name?.toUpperCase() ?? 'MATCH',
                style: GoogleFonts.lexendMega(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeamLogoAndName(fixture.homeTeam),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                    child: Column(
                      children: [
                        if (fixture.isLiveInPlay)
                          Text(
                            fixture.minuteString,
                            style: statusStyle,
                          ),
                        if (fixture.isUpcoming ||
                            fixture.isPaused ||
                            fixture.isLiveOnBreak ||
                            fixture.isLivePenShootout ||
                            fixture.isCompleted)
                          Text(
                            fixture.status,
                            style: statusStyle,
                          ),
                        Text(
                          fixture.scoreString,
                          style: GoogleFonts.lexendMega(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
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
    // @@NOTE: Since every case must return a *list* of widgets, we can't extract
    // the code into separate *real* widgets. So instead we create a bunch of
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
            () => _selectedLineupSubmenu = submenu,
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
        _discussions ??= Discussions(
          fixtureId: fixture.id,
          theme: theme,
          discussionBloc: _discussionBloc,
        );

        return _discussions.build(context: context);
      case FixtureLivescoreSubmenu.PlayerRatings:
        _playerRatings ??= PlayerRatings(
          fixtureId: fixture.id,
          theme: theme,
          playerRatingBloc: _playerRatingBloc,
        );

        return _playerRatings.build(
          context: context,
          onProtectedActionInvoked: _showAuthDialogIfNecessary,
          onProtectedActionCannotProceed: () => setState(() {}),
        );
      case FixtureLivescoreSubmenu.VideoReactions:
        _videoReactions ??= VideoReactions(
          fixtureId: fixture.id,
          selectedVideoReactionFilter: _selectedVideoReactionFilter,
          videoReactionBloc: _videoReactionBloc,
          imageBloc: _imageBloc,
        );

        return _videoReactions.build(
          context: context,
          theme: theme,
          onChangeVideoReactionFilter: (filter) =>
              _selectedVideoReactionFilter = filter,
          onProtectedActionInvoked: _showAuthDialogIfNecessary,
        );
    }

    return [];
  }
}
