import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

import '../discussion/pages/discussion_page.dart';
import '../models/vm/fixture_full_vm.dart';

class Discussions {
  final FixtureFullVm fixture;
  final ThemeData theme;

  final Color _backgroundColor = const Color.fromRGBO(238, 241, 246, 1.0);

  Discussions({
    @required this.fixture,
    @required this.theme,
  });

  List<Widget> build({@required BuildContext context}) {
    var discussions = fixture.discussions;
    return [
      SliverToBoxAdapter(
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: _backgroundColor,
                blurRadius: 0.0,
                spreadRadius: 0.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'Discussion rooms',
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
        itemExtent: 130,
        delegate: SliverChildListDelegate(
          discussions
              .map(
                (discussion) => Container(
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: _backgroundColor,
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Card(
                    color: _backgroundColor,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Text(
                          '${discussion.name[0].toUpperCase()}${discussion.name.substring(1)} discussion',
                          style: GoogleFonts.exo2(
                            textStyle: TextStyle(fontSize: 20),
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios_rounded),
                          padding: const EdgeInsets.all(14),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              DiscussionPage.routeName,
                              arguments: Tuple2(
                                fixture.id,
                                discussion.identifier,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          color: _backgroundColor,
          alignment: Alignment.center,
          child: discussions.isEmpty ? Text('No discussions yet') : null,
        ),
      ),
    ];
  }
}
