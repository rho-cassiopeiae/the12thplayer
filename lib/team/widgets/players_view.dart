import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../general/extensions/kiwi_extension.dart';
import '../bloc/team_actions.dart';
import '../bloc/team_bloc.dart';
import '../bloc/team_states.dart';
import '../models/vm/fixture_player_rating_vm.dart';
import '../models/vm/manager_vm.dart';
import '../models/vm/player_vm.dart';

class PlayersView extends StatefulWidget {
  final double height;
  final double viewFraction;
  final ManagerVm manager;
  final List<PlayerVm> players;

  const PlayersView({
    Key key,
    @required this.height,
    @required this.viewFraction,
    @required this.manager,
    @required this.players,
  })  : assert(
          manager != null && players == null ||
              manager == null && players != null,
        ),
        super(key: key);

  @override
  _PlayersViewState createState() => _PlayersViewState();
}

class _PlayersViewState extends StateWith<PlayersView, TeamBloc> {
  TeamBloc get _teamBloc => service;

  PageController _pageController;

  double _viewportFraction;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _viewportFraction = widget.viewFraction;
    _pageController =
        PageController(initialPage: 0, viewportFraction: _viewportFraction)
          ..addListener(() {
            setState(() {
              _pageOffset = _pageController.page;
            });
          });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          var scale = max(
            _viewportFraction,
            (1.0 - (_pageOffset - index).abs()) + _viewportFraction,
          );

          var angle = (_pageOffset - index).abs();
          if (angle > 0.5) {
            angle = 1.0 - angle;
          }

          var teamMember = widget.manager ?? widget.players[index];

          return Container(
            padding: EdgeInsets.fromLTRB(10.0, 50.0 - scale * 25.0, 10.0, 0.0),
            // color: index % 2 == 0 ? Colors.green : Colors.orange,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle * 1.25),
              alignment: Alignment.center,
              child: LayoutBuilder(
                builder: (context, constraints) => GestureDetector(
                  onTap: () {
                    _teamBloc.dispatchAction(
                      teamMember is PlayerVm
                          ? LoadPlayerRatings(playerId: teamMember.id)
                          : LoadManagerRatings(managerId: teamMember.id),
                    );

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            color: const Color.fromRGBO(0, 0, 0, 0.001),
                            child: DraggableScrollableSheet(
                              initialChildSize: 0.4,
                              minChildSize: 0.2,
                              maxChildSize: 0.75,
                              builder: (context, controller) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(
                                        255, 248, 204, 0.85),
                                    border: Border.all(
                                      color: const Color(0xff46390c),
                                      width: 2.0,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: const Radius.circular(25.0),
                                      topRight: const Radius.circular(25.0),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                          bottom: 8.0,
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          color: const Color(0xff46390c),
                                        ),
                                      ),
                                      StreamBuilder<LoadTeamMemberState>(
                                        initialData: TeamMemberLoading(),
                                        stream: _teamBloc.teamMemberState$,
                                        builder: (context, snapshot) {
                                          var state = snapshot.data;
                                          if (state is TeamMemberLoading) {
                                            return Expanded(
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          }

                                          var ratings =
                                              (state as TeamMemberReady)
                                                  .ratings;

                                          if (ratings.isEmpty) {
                                            return Expanded(
                                              child: Center(
                                                child: Text(
                                                  'No ratings',
                                                  style: TextStyle(
                                                    fontSize: 24.0,
                                                    fontFamily: 'Fifa',
                                                    color:
                                                        const Color(0xff46390c),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          return Expanded(
                                            child: ListView.builder(
                                              controller: controller,
                                              itemCount: ratings.length,
                                              itemBuilder: (_, index) {
                                                return _buildRatingLine(
                                                  ratings[index],
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/player-card.png',
                        ),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: constraints.maxHeight * 496.0 / 792.0,
                      // color: Colors.red.withOpacity(0.3),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 420,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (teamMember is PlayerVm)
                                        Container(
                                          width: 40.0,
                                          height: 40.0,
                                          margin: const EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                              vertical: BorderSide(
                                                color: const Color(0xff46390c),
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            teamMember.number.toString(),
                                            style: GoogleFonts.lexendMega(
                                              fontSize: 18.0,
                                              color: const Color(0xff46390c),
                                            ),
                                          ),
                                        ),
                                      Container(
                                        width: 55.0,
                                        height: 33.0,
                                        margin: const EdgeInsets.only(
                                          bottom: 28.0,
                                        ),
                                        child: Image.network(
                                          teamMember.countryFlagUrl,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: constraints.maxHeight * 0.4,
                                    width: constraints.maxHeight * 0.4,
                                    child: Image.network(
                                      teamMember.imageUrl,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 372,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        24.0, 8.0, 24.0, 0.0),
                                    child: AutoSizeText(
                                      teamMember.fullName,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xff46390c),
                                        fontFamily: 'Fifa',
                                        fontSize: 28.0,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                  Divider(
                                    color: const Color(0xff46390c),
                                    indent: 24.0,
                                    endIndent: 24.0,
                                  ),
                                  if (teamMember.birthDate != null)
                                    Text(
                                      DateFormat.yMMMMd('en_US')
                                          .format(teamMember.birthDate),
                                      style: GoogleFonts.exo2(
                                        textStyle: TextStyle(
                                          color: const Color(0xff46390c),
                                          fontSize: 24.0,
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
                ),
              ),
            ),
          );
        },
        itemCount: widget.manager != null ? 1 : widget.players.length,
      ),
    );
  }

  Widget _buildRatingLine(FixturePlayerRatingVm rating) {
    return Container(
      height: 72.0,
      padding: const EdgeInsets.fromLTRB(16.0, 6.0, 24.0, 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 60.0,
            height: 60.0,
            child: Image.network(
              rating.opponentTeamLogoUrl,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat(
                      'MMMM  dd  yyyy',
                    ).format(rating.fixtureStartTime),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Fifa',
                      color: const Color(0xff46390c),
                    ),
                  ),
                  if (rating.avgRating != null)
                    _buildRatingBar(rating.avgRating),
                  if (rating.avgRating == null)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 15.0,
                      ),
                      child: Text(
                        'No rating',
                        style: GoogleFonts.exo2(
                          fontSize: 18.0,
                          color: const Color(0xff46390c),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (rating.avgRating != null)
            Container(
              width: 40.0,
              height: 40.0,
              decoration: ShapeDecoration(
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(7.0),
                  ),
                  side: BorderSide(
                    color: const Color(0xff46390c),
                    width: 1.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: FittedBox(
                child: Text(
                  rating.avgRating.toString(),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'Fifa',
                    color: const Color(0xff46390c),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _computeBarColor(double rating) {
    var t = rating * 0.1;
    return Color.fromRGBO(
      ((2.0 * (1.0 - t)).clamp(0.0, 1.0) * 200.0).toInt(),
      ((2.0 * t).clamp(0.0, 1.0) * 200.0).toInt(),
      0,
      1.0,
    );
  }

  Widget _buildRatingBar(double avgRating) {
    var avgRatingCeiled = avgRating.ceil();
    var part = ((avgRating - avgRating.floor()) * 10).round();
    if (part == 0) {
      part = 10;
    }

    return Row(
      children: [
        if (avgRatingCeiled > 0)
          Expanded(
            flex: avgRatingCeiled,
            child: Row(
              children: [
                for (int i = 0; i < avgRatingCeiled - 1; ++i)
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        color: _computeBarColor(avgRating),
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      ),
                    ),
                  ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: part,
                            child: Container(
                              color: _computeBarColor(avgRating),
                            ),
                          ),
                          if (part < 10) Spacer(flex: 10 - part),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (avgRatingCeiled < 10) Spacer(flex: 10 - avgRatingCeiled),
      ],
    );
  }
}
