import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/vm/player_vm.dart';
import '../models/vm/team_member_vm.dart';
import '../bloc/team_actions.dart';
import '../bloc/team_states.dart';
import '../widgets/team_member_card.dart';
import '../../general/extensions/color_extension.dart';
import '../../general/extensions/kiwi_extension.dart';
import '../bloc/team_bloc.dart';

class TeamMemberPage extends StatelessWidgetInjected<TeamBloc> {
  static const routeName = '/team/squad/member';

  final TeamMemberVm member;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  TeamMemberPage({@required this.member});

  @override
  Widget buildInjected(BuildContext context, TeamBloc teamBloc) {
    teamBloc.dispatchAction(
      member is PlayerVm
          ? LoadPlayerPerformanceRatings(playerId: member.id)
          : LoadManagerPerformanceRatings(managerId: member.id),
    );

    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _color,
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
        brightness: Brightness.dark,
        centerTitle: true,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 178,
              child: TeamMemberCard(
                teamMember: member,
                borderColor: _color,
              ),
            ),
          ),
          StreamBuilder<TeamMemberState>(
            initialData: TeamMemberLoading(),
            stream: teamBloc.memberState$,
            builder: (context, snapshot) {
              var state = snapshot.data;
              if (state is TeamMemberLoading) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is TeamMemberError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(state.message)),
                );
              }

              var performanceRatings =
                  (state as TeamMemberReady).performanceRatings;

              return SliverFixedExtentList(
                itemExtent: 72,
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var performanceRating = performanceRatings[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 24, 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            child: Image.network(
                              performanceRating.opponentTeamLogoUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat.yMMMMd('en_US')
                                        .format(performanceRating.startTime),
                                    style: GoogleFonts.exo2(
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (performanceRating.avgRating != null)
                                    _buildRatingBar(
                                      performanceRating.avgRating,
                                    ),
                                  if (performanceRating.avgRating == null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 15,
                                      ),
                                      child: Text(
                                        'No rating',
                                        style: GoogleFonts.exo2(
                                          textStyle: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (performanceRating.avgRating != null)
                            Container(
                              width: 40,
                              height: 40,
                              decoration: ShapeDecoration(
                                shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(7),
                                  ),
                                  side: BorderSide(
                                    color: theme.primaryColorLight,
                                    width: 1,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: FittedBox(
                                child: Text(
                                  performanceRating.avgRating.toString(),
                                  style: GoogleFonts.lexendMega(
                                    textStyle: TextStyle(
                                      fontSize: 18,
                                      color: theme.primaryColorDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  childCount: performanceRatings.length,
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  Color _computeBarColor(double rating) {
    var t = rating * 0.1;
    return Color.fromRGBO(
      ((2.0 * (1 - t)).clamp(0, 1) * 200).toInt(),
      ((2.0 * t).clamp(0, 1) * 200).toInt(),
      0,
      1,
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
                      aspectRatio: 1,
                      child: Container(
                        color: _computeBarColor(avgRating),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                      ),
                    ),
                  ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
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

  // List<Widget> _buildVersusLine(
  //   FixturePerformanceRatingVm performanceRating,
  // ) {
  //   var widgets = [
  //     SizedBox(
  //       width: 60,
  //       height: 60,
  //     ),
  //     Text('vs'),
  //     CircleAvatar(
  //       radius: 30,
  //       backgroundImage: NetworkImage(
  //         performanceRating.opponentTeamLogoUrl,
  //         scale: 1.0,
  //       ),
  //     ),
  //   ];

  //   return performanceRating.homeStatus ? widgets : widgets.reversed.toList();
  // }
}
