import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

import '../../../general/bloc/image_actions.dart';
import '../../../general/bloc/image_bloc.dart';
import '../../../general/bloc/image_states.dart';
import '../live_commentary_recording/pages/live_commentary_recording_page.dart';
import '../live_commentary_feed/pages/live_commentary_feed_page.dart';
import '../live_commentary_feed/bloc/live_commentary_feed_actions.dart';
import '../live_commentary_feed/bloc/live_commentary_feed_bloc.dart';
import '../live_commentary_feed/bloc/live_commentary_feed_states.dart';
import '../live_commentary_feed/enums/live_commentary_feed_vote_action.dart';
import '../live_commentary_feed/enums/live_commentary_filter.dart';
import '../models/vm/fixture_full_vm.dart';

class LiveCommentaryFeeds {
  final FixtureFullVm fixture;
  final ThemeData theme;
  LiveCommentaryFilter selectedLiveCommentaryFilter;
  final LiveCommentaryFeedBloc liveCommentaryFeedBloc;
  final ImageBloc imageBloc;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  LiveCommentaryFeeds({
    @required this.fixture,
    @required this.theme,
    @required this.selectedLiveCommentaryFilter,
    @required this.liveCommentaryFeedBloc,
    @required this.imageBloc,
  });

  void _loadLiveCommentaryFeeds(int start) {
    liveCommentaryFeedBloc.dispatchAction(
      LoadLiveCommentaryFeeds(
        fixtureId: fixture.id,
        filter: selectedLiveCommentaryFilter,
        start: start,
      ),
    );
  }

  List<Widget> build({
    @required BuildContext context,
    @required void Function(LiveCommentaryFilter) onChangeLiveCommentaryFilter,
    @required Future<bool> Function(String, String) onProtectedActionInvoked,
  }) {
    _loadLiveCommentaryFeeds(0);
    var width = MediaQuery.of(context).size.width * 0.18;

    return [
      StreamBuilder<LoadLiveCommentaryFeedsState>(
        initialData: LiveCommentaryFeedsLoading(),
        stream: liveCommentaryFeedBloc.feedsState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          var disableFilterButtons = state is LiveCommentaryFeedsLoading ||
              state is LiveCommentaryFeedsError;
          var hideStartRecordingButton = disableFilterButtons ||
              !(state as LiveCommentaryFeedsReady)
                  .fixtureLiveCommentaryFeeds
                  .ongoing;

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
                          onPressed: !disableFilterButtons
                              ? () {
                                  selectedLiveCommentaryFilter =
                                      LiveCommentaryFilter.Top;
                                  onChangeLiveCommentaryFilter(
                                    selectedLiveCommentaryFilter,
                                  );
                                  _loadLiveCommentaryFeeds(0);
                                }
                              : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.new_releases),
                          onPressed: !disableFilterButtons
                              ? () {
                                  selectedLiveCommentaryFilter =
                                      LiveCommentaryFilter.Newest;
                                  onChangeLiveCommentaryFilter(
                                    selectedLiveCommentaryFilter,
                                  );
                                  _loadLiveCommentaryFeeds(0);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Live commentaries',
                    style: GoogleFonts.exo2(
                      textStyle: TextStyle(
                        color: theme.primaryColorDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: !hideStartRecordingButton
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
                                  'Only logged-in users can create live commentary feeds',
                                  'Only confirmed users can create live commentary feeds',
                                );

                                if (canContinue) {
                                  await Navigator.of(context).pushNamed(
                                    LiveCommentaryRecordingPage.routeName,
                                    arguments: Tuple2(
                                      fixture.id,
                                      fixture.teamId,
                                    ),
                                  );

                                  _loadLiveCommentaryFeeds(0);
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
      StreamBuilder<LoadLiveCommentaryFeedsState>(
        initialData: LiveCommentaryFeedsLoading(),
        stream: liveCommentaryFeedBloc.feedsState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is LiveCommentaryFeedsLoading ||
              state is LiveCommentaryFeedsError) {
            return SliverToBoxAdapter(child: SizedBox.shrink());
          }

          var fixtureLiveCommFeeds =
              (state as LiveCommentaryFeedsReady).fixtureLiveCommentaryFeeds;
          var feeds = fixtureLiveCommFeeds.feeds;

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var feed = feeds[index];

                var action = GetProfileImage(
                  username: feed.authorUsername,
                );
                imageBloc.dispatchAction(action);

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
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        LiveCommentaryFeedPage.routeName,
                        arguments: Tuple3(
                          fixture.id,
                          feed.authorId,
                          feed.authorUsername,
                        ),
                      );
                    },
                    child: Card(
                      color: _color,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Row(
                          children: [
                            Container(
                              width: width,
                              height: width * 16.0 / 9.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: FutureBuilder<ImageState>(
                                initialData: ImageLoading(),
                                future: action.state,
                                builder: (context, snapshot) {
                                  var state = snapshot.data;
                                  if (state is ImageLoading) {
                                    return Image.asset(
                                      'assets/images/dummy_profile_image.png',
                                      fit: BoxFit.cover,
                                    );
                                  }

                                  var imageFile =
                                      (state as ImageReady).imageFile;

                                  return Image.file(
                                    imageFile,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 24),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feed.title,
                                  style: GoogleFonts.exo2(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'by ${feed.authorUsername}',
                                  style: GoogleFonts.patuaOne(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  child: Icon(
                                    Icons.arrow_drop_up,
                                    size: 32,
                                    color: feed.voteAction ==
                                            LiveCommentaryFeedVoteAction.Upvote
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
                                      liveCommentaryFeedBloc.dispatchAction(
                                        VoteForLiveCommentaryFeed(
                                          fixtureId: fixture.id,
                                          authorId: feed.authorId,
                                          voteAction:
                                              LiveCommentaryFeedVoteAction
                                                  .Upvote,
                                          fixtureLiveCommentaryFeeds:
                                              fixtureLiveCommFeeds.copy(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: theme.primaryColor,
                                  child: Text(
                                    feed.rating.toString(),
                                    style: GoogleFonts.lexendMega(
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    size: 32,
                                    color: feed.voteAction ==
                                            LiveCommentaryFeedVoteAction
                                                .Downvote
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
                                      liveCommentaryFeedBloc.dispatchAction(
                                        VoteForLiveCommentaryFeed(
                                          fixtureId: fixture.id,
                                          authorId: feed.authorId,
                                          voteAction:
                                              LiveCommentaryFeedVoteAction
                                                  .Downvote,
                                          fixtureLiveCommentaryFeeds:
                                              fixtureLiveCommFeeds.copy(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: feeds.length,
            ),
          );
        },
      ),
      StreamBuilder<LoadLiveCommentaryFeedsState>(
        initialData: LiveCommentaryFeedsLoading(),
        stream: liveCommentaryFeedBloc.feedsState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is LiveCommentaryFeedsLoading) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                color: _color,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is LiveCommentaryFeedsError) {
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
