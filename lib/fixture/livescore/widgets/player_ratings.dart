import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../player_rating/bloc/player_rating_actions.dart';
import '../player_rating/bloc/player_rating_bloc.dart';
import '../player_rating/bloc/player_rating_states.dart';
import '../player_rating/models/vm/player_ratings_vm.dart';

class PlayerRatings {
  final int fixtureId;
  final ThemeData theme;
  final PlayerRatingBloc playerRatingBloc;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  PlayerRatings({
    @required this.fixtureId,
    @required this.theme,
    @required this.playerRatingBloc,
  }) {
    _loadPlayerRatings();
  }

  void _loadPlayerRatings() {
    playerRatingBloc.dispatchAction(
      LoadPlayerRatings(fixtureId: fixtureId),
    );
  }

  bool _shouldDisplayRating(
    bool ratingsFinalized,
    PlayerRatingVm playerRating,
  ) =>
      ratingsFinalized || playerRating.userRating != null;

  List<Widget> build({
    @required BuildContext context,
    @required Future<bool> Function() onProtectedActionInvoked,
    @required void Function() onProtectedActionCannotProceed,
  }) {
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
            children: [
              Spacer(),
              Text(
                'Ratings',
                style: GoogleFonts.exo2(
                  textStyle: TextStyle(
                    color: theme.primaryColorDark,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.grey,
                    ),
                    onPressed: _loadPlayerRatings,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      StreamBuilder<LoadPlayerRatingsState>(
        initialData: PlayerRatingsLoading(),
        stream: playerRatingBloc.playerRatingsState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is PlayerRatingsLoading || state is PlayerRatingsError) {
            return SliverToBoxAdapter(child: SizedBox.shrink());
          }

          var playerRatings = (state as PlayerRatingsReady).playerRatings;

          bool ratingsFinalized = playerRatings.finalized;

          return SliverFixedExtentList(
            itemExtent: 258.0,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var playerRating = playerRatings.ratings[index];
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
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0.0,
                        height: 206.0,
                        left: 25.0,
                        right: 25.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0x554A47A3),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10.0,
                        height: 216.0,
                        left: 15.0,
                        right: 15.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0x774A47A3),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20.0,
                        height: 226.0,
                        left: 0.0,
                        right: 0.0,
                        child: Card(
                          elevation: 5.0,
                          color: const Color(0xff4A47A3),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.black26,
                              width: 4.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
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
                                        playerRating.displayName,
                                        style: GoogleFonts.exo2(
                                          textStyle: TextStyle(
                                            fontSize: 30.0,
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
                                        elevation: 7.0,
                                        color: const Color(0xaa5465ff),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12.0),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              12.0, 16.0, 12.0, 6.0),
                                          child: Column(
                                            children: [
                                              DottedBorder(
                                                borderType: BorderType.RRect,
                                                radius: Radius.circular(12.0),
                                                color: Colors.white,
                                                dashPattern: const [6.0, 5.0],
                                                strokeWidth: 3.0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 4.0,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(12.0),
                                                  ),
                                                  child: Container(
                                                    child: Text(
                                                      _shouldDisplayRating(
                                                        ratingsFinalized,
                                                        playerRating,
                                                      )
                                                          ? playerRating
                                                              .avgRating
                                                          : '**',
                                                      style: GoogleFonts
                                                          .lexendMega(
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 26.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8.0),
                                              Text(
                                                _shouldDisplayRating(
                                                  ratingsFinalized,
                                                  playerRating,
                                                )
                                                    ? playerRating.totalVoters
                                                    : '(** votes)',
                                                style: GoogleFonts.teko(
                                                  textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.0,
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
                                            angleRange: 300.0,
                                            size: 165.0,
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
                                          min: 0.0,
                                          max: 10.0,
                                          initialValue:
                                              playerRating.userRating ?? 0.0,
                                          onChangeEnd: !ratingsFinalized
                                              ? (value) async {
                                                  bool canProceed =
                                                      await onProtectedActionInvoked();
                                                  if (canProceed) {
                                                    playerRatingBloc
                                                        .dispatchAction(
                                                      RatePlayer(
                                                        fixtureId: fixtureId,
                                                        participantKey:
                                                            playerRating
                                                                .participantKey,
                                                        rating: value,
                                                      ),
                                                    );
                                                  } else {
                                                    onProtectedActionCannotProceed();
                                                  }
                                                }
                                              : null,
                                          innerWidget: (value) {
                                            int rating = value.floor();
                                            return Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Transform.translate(
                                                offset: Offset(
                                                  rating < 10 ? 40.0 : 20.0,
                                                  20.0,
                                                ),
                                                child: Text(
                                                  rating.toString(),
                                                  style: GoogleFonts.lexendMega(
                                                    textStyle: TextStyle(
                                                      fontSize: 34.0,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Container(
                                          width: 130.0,
                                          height: 130.0,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 3.0,
                                              color: Colors.white,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(65.0),
                                            ),
                                            color: const Color(0xff4361ee),
                                          ),
                                        ),
                                        Container(
                                          width: 120.0,
                                          height: 120.0,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(60.0),
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Image.network(
                                            playerRating.imageUrl,
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
              childCount: playerRatings.ratings.length,
            ),
          );
        },
      ),
      StreamBuilder<LoadPlayerRatingsState>(
        initialData: PlayerRatingsLoading(),
        stream: playerRatingBloc.playerRatingsState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is PlayerRatingsLoading) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                color: _color,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is PlayerRatingsError) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                color: _color,
              ),
            );
          }

          var playerRatings = (state as PlayerRatingsReady).playerRatings;

          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: _color,
              alignment: Alignment.center,
              child: playerRatings.ratings.isEmpty ? Text('No ratings') : null,
            ),
          );
        },
      ),
    ];
  }
}
