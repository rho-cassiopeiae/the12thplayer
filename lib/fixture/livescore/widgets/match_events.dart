import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../icons/football.dart';
import '../models/vm/fixture_full_vm.dart';
import '../models/vm/match_events_vm.dart';

class MatchEvents {
  final FixtureFullVm fixture;
  final ThemeData theme;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  MatchEvents({
    @required this.fixture,
    @required this.theme,
  });

  List<Widget> build() {
    var eventGroups = fixture.events.groups;
    return [
      SliverToBoxAdapter(
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: _color,
                blurRadius: 0.0,
                spreadRadius: 0.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'Match events',
            style: GoogleFonts.exo2(
              textStyle: TextStyle(
                color: theme.primaryColorDark,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            var eventGroup = eventGroups[index];
            var homeEvents = eventGroup.homeTeamEvents;
            var awayEvents = eventGroup.awayTeamEvents;

            var homeSubEventCount =
                homeEvents.where((event) => event.isSub).length;
            var homeNonSubEventCount = homeEvents.length - homeSubEventCount;

            var awaySubEventCount =
                awayEvents.where((event) => event.isSub).length;
            var awayNonSubEventCount = awayEvents.length - awaySubEventCount;

            var height = max(
                  homeNonSubEventCount * 38 + homeSubEventCount * 68,
                  awayNonSubEventCount * 38 + awaySubEventCount * 68,
                ) +
                16.0;

            // SliverList provides to its childred unbounded constraints in both dimensions

            return Container(
              decoration: BoxDecoration(
                color: _color,
                boxShadow: [
                  BoxShadow(
                    color: _color,
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                top: index == 0 ? 2.0 : 0.0,
                bottom: index == eventGroups.length - 1 ? 8.0 : 0.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: homeEvents
                            .map((event) => _buildEventCard(event, true))
                            .toList(),
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 9,
                        height: height,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                index == 0 ? Radius.circular(4.5) : Radius.zero,
                            topRight:
                                index == 0 ? Radius.circular(4.5) : Radius.zero,
                            bottomLeft: index == eventGroups.length - 1
                                ? Radius.circular(4.5)
                                : Radius.zero,
                            bottomRight: index == eventGroups.length - 1
                                ? Radius.circular(4.5)
                                : Radius.zero,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black87,
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                              offset: Offset(0.0, index > 0 ? -2.0 : 0.0),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.black87,
                        radius: 18,
                        child: FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                            ),
                            child: Text(
                              eventGroup.minute,
                              style: GoogleFonts.lexendMega(
                                textStyle: TextStyle(
                                  color: _color,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: awayEvents
                            .map((event) => _buildEventCard(event, false))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: eventGroups.length,
        ),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          color: _color,
          alignment: Alignment.center,
          child: eventGroups.isEmpty ? Text('No events yet') : null,
        ),
      ),
    ];
  }

  Widget _buildEvent(String eventType, String playerName, bool homeEvent) {
    var widgets = [
      Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: _buildEventIcon(eventType, homeEvent),
      ),
      SizedBox(width: 4),
      Expanded(
        child: Text(
          playerName,
          style: GoogleFonts.exo2(
            textStyle: TextStyle(
              color: _getEventFontColor(eventType),
              fontWeight: FontWeight.bold,
            ),
          ),
          softWrap: false,
          overflow: TextOverflow.fade,
          textAlign: TextAlign.center,
        ),
      ),
    ];

    if (!homeEvent) {
      widgets = widgets.reversed.toList();
    }

    return Row(children: widgets);
  }

  Widget _buildEventCard(MatchEventVm event, bool homeEvent) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      color: _getEventCardColor(event.type),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: !event.isSub
            ? _buildEvent(event.type, event.playerName, homeEvent)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEvent('sub-on', event.playerName, homeEvent),
                  _buildEvent(
                    'sub-off',
                    event.relatedPlayerName ?? '',
                    homeEvent,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEventIcon(String eventType, bool homeEvent) {
    switch (eventType) {
      case 'goal':
      case 'penalty':
        return Icon(
          Football.football_ball_variant_1,
          color: Colors.white,
          size: 20.0,
        );
      case 'own-goal':
        return Icon(
          Football.football_ball_variant_1,
          color: Colors.red[200],
          size: 20.0,
        );
      case 'yellowcard':
      case 'redcard':
      case 'yellowred':
        return Icon(
          Football.football_yellow_warning_card,
          size: 22.0,
        );
      case 'sub-off':
        return homeEvent
            ? Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.red,
                size: 20.0,
              )
            : Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.red,
                size: 20.0,
              );
      case 'sub-on':
        return homeEvent
            ? Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.green,
                size: 20.0,
              )
            : Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.green,
                size: 20.0,
              );
      default:
        return Icon(
          Football.black_and_white_whistle_variant,
          size: 24.0,
        );
    }
  }

  Color _getEventCardColor(String eventType) {
    switch (eventType) {
      case 'goal':
      case 'penalty':
      case 'own-goal':
        return const Color.fromRGBO(98, 16, 239, 1.0);
      case 'yellowcard':
        return const Color.fromRGBO(255, 230, 68, 1.0);
      case 'redcard':
      case 'yellowred':
        return const Color.fromRGBO(252, 110, 110, 1.0);
      case 'substitution':
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  Color _getEventFontColor(String eventType) {
    switch (eventType) {
      case 'goal':
      case 'penalty':
      case 'own-goal':
        return Colors.white;
      case 'yellowcard':
        return Colors.black87;
      case 'redcard':
      case 'yellowred':
        return Colors.black;
      case 'sub-on':
      case 'sub-off':
        return Colors.black87;
      default:
        return Colors.black;
    }
  }
}
