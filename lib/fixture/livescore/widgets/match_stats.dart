import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/vm/fixture_full_vm.dart';

class MatchStats {
  final FixtureFullVm fixture;
  final ThemeData theme;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  MatchStats({
    @required this.fixture,
    @required this.theme,
  });

  Color _computeBorderColor(Color color) {
    var luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255.0;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  List<Widget> build() {
    var homeColor = fixture.colors.homeTeam;
    if (homeColor == null) {
      homeColor = fixture.homeTeam.id == fixture.teamId
          ? theme.primaryColorDark
          : theme.accentColor;
    }

    var awayColor = fixture.colors.awayTeam;
    if (awayColor == null) {
      awayColor = fixture.awayTeam.id == fixture.teamId
          ? theme.primaryColorDark
          : theme.accentColor;
    }

    var borderColorHome = _computeBorderColor(homeColor);
    var borderColorAway = _computeBorderColor(awayColor);

    var stats = fixture.stats.stats;

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
          child: Text(
            'Stats',
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
        itemExtent: 64.0,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            var stat = stats[index];
            bool drawBorder;
            if (stat.homeTeamValue == 0 && stat.awayTeamValue == 0) {
              drawBorder = true;
            } else if (stat.homeTeamValue == 0) {
              drawBorder = borderColorAway == Colors.black;
            } else if (stat.awayTeamValue == 0) {
              drawBorder = borderColorHome == Colors.black;
            } else {
              drawBorder = !(borderColorHome == Colors.white &&
                  borderColorAway == Colors.white);
            }

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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      '${stat.homeTeamValue}${stat.modifier}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: GoogleFonts.lexendMega(),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          stat.name,
                          style: GoogleFonts.exo2(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                        Container(
                          height: 18.0,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            border: drawBorder
                                ? Border.all(
                                    width: 2.0,
                                    color: Colors.black87,
                                  )
                                : null,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              Expanded(
                                flex: stat.homeTeamValue,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: homeColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      bottomLeft: Radius.circular(12.0),
                                      topRight: stat.awayTeamValue == 0
                                          ? Radius.circular(12.0)
                                          : Radius.zero,
                                      bottomRight: stat.awayTeamValue == 0
                                          ? Radius.circular(12.0)
                                          : Radius.zero,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: stat.awayTeamValue,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: awayColor,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(12.0),
                                      bottomRight: Radius.circular(12.0),
                                      topLeft: stat.homeTeamValue == 0
                                          ? Radius.circular(12.0)
                                          : Radius.zero,
                                      bottomLeft: stat.homeTeamValue == 0
                                          ? Radius.circular(12.0)
                                          : Radius.zero,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${stat.awayTeamValue}${stat.modifier}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: GoogleFonts.lexendMega(),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: stats.length,
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
          height: 24.0,
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
        ),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          color: _color,
          alignment: Alignment.center,
          child: stats.isEmpty ? Text('No stats yet') : null,
        ),
      ),
    ];
  }
}
