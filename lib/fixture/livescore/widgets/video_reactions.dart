import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/video_page.dart';
import '../video_reaction/enums/video_reaction_vote_action.dart';
import '../models/vm/fixture_full_vm.dart';
import '../video_reaction/bloc/video_reaction_actions.dart';
import '../video_reaction/bloc/video_reaction_bloc.dart';
import '../video_reaction/bloc/video_reaction_states.dart';
import '../video_reaction/enums/video_reaction_filter.dart';
import '../video_reaction/pages/video_reaction_page.dart';

class VideoReactions {
  final FixtureFullVm fixture;
  final ThemeData theme;
  VideoReactionFilter selectedVideoReactionFilter;
  final VideoReactionBloc videoReactionBloc;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  VideoReactions({
    @required this.fixture,
    @required this.theme,
    @required this.selectedVideoReactionFilter,
    @required this.videoReactionBloc,
  });

  void _loadVideoReactions(int start) {
    videoReactionBloc.dispatchAction(
      LoadVideoReactions(
        fixtureId: fixture.id,
        filter: selectedVideoReactionFilter,
        start: start,
      ),
    );
  }

  List<Widget> build({
    @required BuildContext context,
    @required void Function(VideoReactionFilter) onChangeVideoReactionFilter,
    @required Future<bool> Function(String, String) onProtectedActionInvoked,
  }) {
    _loadVideoReactions(0);

    return [
      StreamBuilder<LoadVideoReactionsState>(
        initialData: VideoReactionsLoading(),
        stream: videoReactionBloc.videoReactionsState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          var disableButtons =
              state is VideoReactionsLoading || state is VideoReactionsError;

          return SliverToBoxAdapter(
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
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.leaderboard),
                          onPressed: !disableButtons
                              ? () {
                                  selectedVideoReactionFilter =
                                      VideoReactionFilter.Top;
                                  onChangeVideoReactionFilter(
                                    selectedVideoReactionFilter,
                                  );
                                  _loadVideoReactions(0);
                                }
                              : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.new_releases),
                          onPressed: !disableButtons
                              ? () {
                                  selectedVideoReactionFilter =
                                      VideoReactionFilter.Newest;
                                  onChangeVideoReactionFilter(
                                    selectedVideoReactionFilter,
                                  );
                                  _loadVideoReactions(0);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Video reactions',
                    style: GoogleFonts.exo2(
                      textStyle: TextStyle(
                        color: theme.primaryColorDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: !disableButtons
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                              icon: Icon(
                                Icons.live_tv,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                bool canContinue =
                                    await onProtectedActionInvoked(
                                  'Only logged-in users can post a video reaction',
                                  'Only confirmed users can post a video reaction',
                                );

                                if (canContinue) {
                                  await Navigator.of(context).pushNamed(
                                    VideoReactionPage.routeName,
                                    arguments: fixture.id,
                                  );

                                  _loadVideoReactions(0);
                                }
                              },
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      StreamBuilder<LoadVideoReactionsState>(
        initialData: VideoReactionsLoading(),
        stream: videoReactionBloc.videoReactionsState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is VideoReactionsLoading || state is VideoReactionsError) {
            return SliverToBoxAdapter(child: SizedBox.shrink());
          }

          var fixtureVideoReactions =
              (state as VideoReactionsReady).fixtureVideoReactions;
          var reactions = fixtureVideoReactions.reactions;

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var reaction = reactions[index];

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
                  child: Stack(
                    children: [
                      Card(
                        color: _color,
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                color: Colors.black87,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.network(
                                      reaction.thumbnailUrl,
                                      fit: BoxFit.contain,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          VideoPage.routeName,
                                          arguments: reaction.videoId,
                                        );
                                      },
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white54,
                                        size: 80,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      reaction.title,
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          child: Icon(
                                            Icons.thumb_down,
                                            color: reaction.downvoted
                                                ? Colors.orange
                                                : null,
                                          ),
                                          onTap: () async {
                                            bool canContinue =
                                                await onProtectedActionInvoked(
                                              'Only logged-in users can vote',
                                              'Only confirmed users can vote',
                                            );

                                            if (canContinue) {
                                              videoReactionBloc.dispatchAction(
                                                VoteForVideoReaction(
                                                  fixtureId: fixture.id,
                                                  authorId: reaction.authorId,
                                                  voteAction:
                                                      VideoReactionVoteAction
                                                          .Downvote,
                                                  fixtureVideoReactions:
                                                      fixtureVideoReactions
                                                          .copy(),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        Text(
                                          reaction.rating.toString(),
                                          style: GoogleFonts.lexendMega(
                                            fontSize: 18,
                                          ),
                                        ),
                                        GestureDetector(
                                          child: Icon(
                                            Icons.thumb_up,
                                            color: reaction.upvoted
                                                ? Colors.orange
                                                : null,
                                          ),
                                          onTap: () async {
                                            bool canContinue =
                                                await onProtectedActionInvoked(
                                              'Only logged-in users can vote',
                                              'Only confirmed users can vote',
                                            );

                                            if (canContinue) {
                                              videoReactionBloc.dispatchAction(
                                                VoteForVideoReaction(
                                                  fixtureId: fixture.id,
                                                  authorId: reaction.authorId,
                                                  voteAction:
                                                      VideoReactionVoteAction
                                                          .Upvote,
                                                  fixtureVideoReactions:
                                                      fixtureVideoReactions
                                                          .copy(),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 12,
                        child: Card(
                          color: const Color(0xff2b2d42),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Text(
                              reaction.authorUsername,
                              style: GoogleFonts.patuaOne(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: reactions.length,
            ),
          );
        },
      ),
      StreamBuilder<LoadVideoReactionsState>(
        initialData: VideoReactionsLoading(),
        stream: videoReactionBloc.videoReactionsState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is VideoReactionsLoading) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                color: _color,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is VideoReactionsError) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                color: _color,
                alignment: Alignment.center,
                child: Text(state.message),
              ),
            );
          }

          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: _color,
            ),
          );
        },
      ),
    ];
  }
}
