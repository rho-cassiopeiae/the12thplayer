import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../enums/lineup_submenu.dart';
import '../models/vm/fixture_full_vm.dart';
import '../models/vm/lineups_vm.dart';
import 'player_dummy.dart';
import 'bench_player_dummy.dart';

class Lineups {
  final FixtureFullVm fixture;
  final ThemeData theme;
  final LineupSubmenu selectedLineupSubmenu;
  final ScrollController benchPlayersScrollController;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);
  Color _teamColor;
  Color _fontColor;
  LineupVm _lineup;

  Lineups({
    @required this.fixture,
    @required this.theme,
    @required this.selectedLineupSubmenu,
    @required this.benchPlayersScrollController,
  }) {
    if (selectedLineupSubmenu == LineupSubmenu.HomeTeam) {
      _teamColor = fixture.colors.homeTeam;
      if (_teamColor == null) {
        _teamColor = fixture.homeTeam.id == fixture.teamId
            ? theme.primaryColorDark
            : theme.colorScheme.secondary;
      }
    } else {
      _teamColor = fixture.colors.awayTeam;
      if (_teamColor == null) {
        _teamColor = fixture.awayTeam.id == fixture.teamId
            ? theme.primaryColorDark
            : theme.colorScheme.secondary;
      }
    }

    _fontColor = _computeFontColor(_teamColor);

    _lineup = selectedLineupSubmenu == LineupSubmenu.HomeTeam
        ? fixture.lineups.homeTeam
        : fixture.lineups.awayTeam;
  }

  Color _computeFontColor(Color color) {
    var luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255.0;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildPlayerCard(PlayerVm player) {
    return Container(
      decoration: BoxDecoration(
        color: _color,
        boxShadow: [
          BoxShadow(
            color: _color,
            blurRadius: 0.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Card(
        color: _color,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 34.0,
                backgroundColor: _teamColor,
                child: Text(
                  player.number.toString(),
                  style: TextStyle(color: _fontColor),
                ),
              ),
              SizedBox(width: 12.0),
              Text(
                player.displayName,
                style: GoogleFonts.exo2(
                  textStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 26.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBackupFormationPresentation() {
    // @@TODO: Improve design.
    var startingXI = _lineup.startingXI;
    var subs = _lineup.subs;

    return [
      SliverFixedExtentList(
        itemExtent: 100.0,
        delegate: SliverChildListDelegate(
          startingXI.map((player) => _buildPlayerCard(player)).toList(),
        ),
      ),
      if (subs.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: Container(
            height: 50.0,
            decoration: BoxDecoration(
              color: _color,
              boxShadow: [
                BoxShadow(
                  color: _color,
                  blurRadius: 0.0,
                  spreadRadius: 0.0,
                  offset: Offset(0.0, 2.0),
                ),
              ],
            ),
            alignment: Alignment.bottomCenter,
            child: Text(
              'On the bench',
              style: GoogleFonts.exo2(
                textStyle: TextStyle(
                  color: theme.primaryColorDark,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 100.0,
          delegate: SliverChildListDelegate(
            subs.map((player) => _buildPlayerCard(player)).toList(),
          ),
        ),
      ],
      SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          color: _color,
        ),
      ),
    ];
  }

  List<Widget> build({
    @required BuildContext context,
    @required void Function(LineupSubmenu submenu) onChangeLineupSubmenu,
  }) {
    var width = MediaQuery.of(context).size.width;
    var height = width * 1.467;
    var scaleHeight = height / 603.0;
    var scaleWidth = width / 411.0;

    // var manager = lineup.manager; @@TODO: Display manager somewhere.
    var startingXI = _lineup.startingXI;
    var subs = _lineup.subs;

    return [
      SliverToBoxAdapter(
        child: Container(
          height: 50.0,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
            boxShadow: [
              BoxShadow(
                color: _color,
                blurRadius: 0.0,
                spreadRadius: 0.0,
                offset: Offset(0.0, 2.0),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                child: Text('Home team'),
                onPressed: () {
                  if (selectedLineupSubmenu != LineupSubmenu.HomeTeam) {
                    onChangeLineupSubmenu(LineupSubmenu.HomeTeam);
                  }
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    selectedLineupSubmenu == LineupSubmenu.HomeTeam
                        ? theme.primaryColorDark
                        : theme.primaryColorLight,
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
              ),
              Text(
                'Lineups',
                style: GoogleFonts.exo2(
                  textStyle: TextStyle(
                    color: theme.primaryColorDark,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                child: Text('Guest team'),
                onPressed: () {
                  if (selectedLineupSubmenu != LineupSubmenu.GuestTeam) {
                    onChangeLineupSubmenu(LineupSubmenu.GuestTeam);
                  }
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    selectedLineupSubmenu == LineupSubmenu.GuestTeam
                        ? theme.primaryColorDark
                        : theme.primaryColorLight,
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      if (_lineup.canDrawFormation)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: _color,
                height: height,
                child: Image.asset(
                  'assets/images/pitch.png',
                  fit: BoxFit.cover,
                ),
              ),
              ...startingXI.map(
                (player) => Positioned(
                  top: scaleHeight * player.formationPosition.top,
                  left: player.formationPosition.left == null
                      ? null
                      : scaleWidth * player.formationPosition.left,
                  right: player.formationPosition.right == null
                      ? null
                      : scaleWidth * player.formationPosition.right,
                  width: 100.0,
                  height: player.formationPosition.radius * 2.0 + 18.0,
                  child: PlayerDummy(
                    player: player,
                    color: _teamColor,
                    fontColor: _fontColor,
                    radius: player.formationPosition.radius,
                  ),
                ),
              ),
              if (subs.isNotEmpty)
                Positioned(
                  top: scaleHeight * 490.0,
                  height: 76.0,
                  left: 10.0,
                  right: 10.0,
                  child: Container(
                    child: FadingEdgeScrollView.fromScrollView(
                      gradientFractionOnStart: 0.4,
                      gradientFractionOnEnd: 0.4,
                      child: ListView(
                        controller: benchPlayersScrollController,
                        scrollDirection: Axis.horizontal,
                        children: subs
                            .map(
                              (player) => Container(
                                width: 100.0,
                                child: BenchPlayerDummy(
                                  player: player,
                                  radius: 32.0,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      if (!_lineup.canDrawFormation && startingXI.length == 11)
        ..._buildBackupFormationPresentation(),
      if (startingXI.length != 11)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(
            color: _color,
            child: Center(child: Text('No lineups yet')),
          ),
        ),
    ];
  }
}
