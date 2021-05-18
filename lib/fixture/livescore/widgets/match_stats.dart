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

    var stats = fixture.stats.stats;

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
            'Stats',
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
      SliverFixedExtentList(
        itemExtent: 64,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            var stat = stats[index];
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
                          style: GoogleFonts.exo2(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            border: Border.all(
                              width: 2,
                              color: Colors.black87,
                            ),
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
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                      topRight: stat.awayTeamValue == 0
                                          ? Radius.circular(12)
                                          : Radius.zero,
                                      bottomRight: stat.awayTeamValue == 0
                                          ? Radius.circular(12)
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
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                      topLeft: stat.homeTeamValue == 0
                                          ? Radius.circular(12)
                                          : Radius.zero,
                                      bottomLeft: stat.homeTeamValue == 0
                                          ? Radius.circular(12)
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
          height: 24,
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
