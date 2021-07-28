import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../performance_rating/bloc/performance_rating_actions.dart';
import '../performance_rating/bloc/performance_rating_bloc.dart';
import '../performance_rating/bloc/performance_rating_states.dart';
import '../performance_rating/models/vm/performance_ratings_vm.dart';
import '../models/vm/fixture_full_vm.dart';

class PerformanceRatings {
  final FixtureFullVm fixture;
  final ThemeData theme;
  final PerformanceRatingBloc performanceRatingBloc;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  PerformanceRatings({
    @required this.fixture,
    @required this.theme,
    @required this.performanceRatingBloc,
  });

  void _loadPerformanceRatings() {
    performanceRatingBloc.dispatchAction(
      LoadPerformanceRatings(fixtureId: fixture.id),
    );
  }

  bool _shouldDisplayRating(
    bool ratingsFinalized,
    PerformanceRatingVm performanceRating,
  ) =>
      ratingsFinalized || performanceRating.myRating != null;

  List<Widget> build({@required BuildContext context}) {
    _loadPerformanceRatings();

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
      StreamBuilder<LoadPerformanceRatingsState>(
        initialData: PerformanceRatingsLoading(),
        stream: performanceRatingBloc.state$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is PerformanceRatingsLoading ||
              state is PerformanceRatingsError) {
            return SliverToBoxAdapter(child: SizedBox.shrink());
          }

          var performanceRatings =
              (state as PerformanceRatingsReady).performanceRatings;

          bool ratingsFinalized = performanceRatings.isFinalized;

          return SliverFixedExtentList(
            itemExtent: 258,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var performanceRating = performanceRatings.ratings[index];
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
                            color: const Color(0x554A47A3),
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
                            color: const Color(0x774A47A3),
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
                          color: const Color(0xff4A47A3),
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
                                        color: const Color(0xaa5465ff),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 4,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(12),
                                                  ),
                                                  child: Container(
                                                    child: Text(
                                                      _shouldDisplayRating(
                                                        ratingsFinalized,
                                                        performanceRating,
                                                      )
                                                          ? performanceRating
                                                              .avgRating
                                                          : '**',
                                                      style: GoogleFonts
                                                          .lexendMega(
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
                                                  ratingsFinalized,
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
                                                const Color(0xff5465ff),
                                                const Color(0xff788bff),
                                                const Color(0xffb0c1ff),
                                              ],
                                            ),
                                          ),
                                          min: 0,
                                          max: 10,
                                          initialValue:
                                              performanceRating.myRating ?? 0.0,
                                          onChangeEnd: !ratingsFinalized
                                              ? (value) {
                                                  performanceRatingBloc
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
                                            color: const Color(0xff4361ee),
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
                                            performanceRating
                                                .participantImageUrl,
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
              childCount: performanceRatings.ratings.length,
            ),
          );
        },
      ),
      StreamBuilder<LoadPerformanceRatingsState>(
        initialData: PerformanceRatingsLoading(),
        stream: performanceRatingBloc.state$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is PerformanceRatingsLoading) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                color: _color,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is PerformanceRatingsError) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                color: _color,
                alignment: Alignment.center,
                child: Text(state.message),
              ),
            );
          }

          var performanceRatings =
              (state as PerformanceRatingsReady).performanceRatings;

          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: _color,
              alignment: Alignment.center,
              child: performanceRatings.ratings.isEmpty
                  ? Text('No ratings yet')
                  : null,
            ),
          );
        },
      ),
    ];
  }
}
