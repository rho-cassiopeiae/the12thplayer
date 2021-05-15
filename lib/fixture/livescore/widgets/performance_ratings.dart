import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../bloc/fixture_livescore_actions.dart';
import '../bloc/fixture_livescore_bloc.dart';
import '../models/vm/fixture_full_vm.dart';
import '../models/vm/performance_ratings_vm.dart';
import '../../../general/extensions/color_extension.dart';

class PerformanceRatings {
  final FixtureFullVm fixture;
  final ThemeData theme;
  final FixtureLivescoreBloc fixtureLivescoreBloc;

  final Color _backgroundColor = const Color.fromRGBO(238, 241, 246, 1.0);

  PerformanceRatings({
    @required this.fixture,
    @required this.theme,
    @required this.fixtureLivescoreBloc,
  });

  bool _shouldDisplayRating(PerformanceRatingVm performanceRating) {
    return fixture.isCompletedAndInactive || performanceRating.myRating != null;
  }

  List<Widget> build() {
    var performanceRatings = fixture.performanceRatings.ratings;
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
            'Ratings',
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
        itemExtent: 258,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            var performanceRating = performanceRatings[index];
            return Container(
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
                horizontal: 12,
                vertical: 6,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    height: 206,
                    left: 25,
                    right: 25,
                    child: Container(
                      decoration: BoxDecoration(
                        color: HexColor.fromHex('554059ad'),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    height: 216,
                    left: 15,
                    right: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: HexColor.fromHex('774059ad'), // 3066be
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    height: 226,
                    left: 0,
                    right: 0,
                    child: Card(
                      elevation: 5,
                      color: HexColor.fromHex('4059ad'),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.black26,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 8.0,
                              ),
                              child: Column(
                                children: [
                                  Spacer(flex: 2),
                                  AutoSizeText(
                                    performanceRating.participantName,
                                    style: GoogleFonts.exo2(
                                      textStyle: TextStyle(
                                        fontSize: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Spacer(),
                                  Card(
                                    margin: EdgeInsets.zero,
                                    elevation: 7,
                                    color: HexColor.fromHex('5465ff'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 16, 12, 6),
                                      child: Column(
                                        children: [
                                          DottedBorder(
                                            borderType: BorderType.RRect,
                                            radius: Radius.circular(12),
                                            color: Colors.white,
                                            dashPattern: [6, 5],
                                            strokeWidth: 3,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                              child: Container(
                                                child: Text(
                                                  _shouldDisplayRating(
                                                    performanceRating,
                                                  )
                                                      ? performanceRating
                                                          .avgRating
                                                      : '**',
                                                  style: GoogleFonts.lexendMega(
                                                    textStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 26,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            _shouldDisplayRating(
                                              performanceRating,
                                            )
                                                ? performanceRating
                                                    .totalVotersString
                                                : '(** votes)',
                                            style: GoogleFonts.teko(
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Spacer(flex: 2),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SleekCircularSlider(
                                      appearance: CircularSliderAppearance(
                                        angleRange: 300,
                                        size: 165,
                                        animationEnabled: false,
                                        customColors: CustomSliderColors(
                                          trackColor: Colors.white70,
                                          progressBarColors: [
                                            HexColor.fromHex('9bb1ff'),
                                            HexColor.fromHex('788bff'),
                                            HexColor.fromHex('5465ff'),
                                            // HexColor.fromHex('7209b7'),
                                            // HexColor.fromHex('4361ee'),
                                            // HexColor.fromHex('caf0f8'),
                                          ],
                                        ),
                                      ),
                                      min: 0,
                                      max: 10,
                                      initialValue:
                                          performanceRating.myRating ?? 0.0,
                                      onChangeEnd:
                                          !fixture.isCompletedAndInactive
                                              ? (value) {
                                                  fixtureLivescoreBloc
                                                      .dispatchAction(
                                                    RateParticipantOfGivenFixture(
                                                      fixtureId: fixture.id,
                                                      participantIdentifier:
                                                          performanceRating
                                                              .participantIdentifier,
                                                      rating: value,
                                                    ),
                                                  );
                                                }
                                              : null,
                                      innerWidget: (value) {
                                        int rating = value.floor();
                                        return Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Transform.translate(
                                            offset: Offset(
                                              rating < 10 ? 40 : 20,
                                              20,
                                            ),
                                            child: Text(
                                              rating.toString(),
                                              style: GoogleFonts.lexendMega(
                                                textStyle: TextStyle(
                                                  fontSize: 34,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Container(
                                      width: 130,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 3,
                                          color: Colors.white,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(65),
                                        ),
                                        color: HexColor.fromHex('4361ee'),
                                      ),
                                    ),
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(60),
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(
                                        performanceRating.participantImageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: performanceRatings.length,
        ),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          color: _backgroundColor,
          alignment: Alignment.center,
          child: performanceRatings.isEmpty ? Text('No ratings yet') : null,
        ),
      ),
    ];
  }
}
