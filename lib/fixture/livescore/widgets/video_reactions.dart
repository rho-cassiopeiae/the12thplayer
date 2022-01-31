import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'video_reaction_rating.dart';
import '../../../general/bloc/image_states.dart';
import '../../../general/bloc/image_actions.dart';
import '../../../general/bloc/image_bloc.dart';
import '../pages/video_page.dart';
import '../video_reaction/bloc/video_reaction_actions.dart';
import '../video_reaction/bloc/video_reaction_bloc.dart';
import '../video_reaction/bloc/video_reaction_states.dart';
import '../video_reaction/enums/video_reaction_filter.dart';
import '../video_reaction/pages/video_reaction_page.dart';

class VideoReactions {
  final int fixtureId;
  VideoReactionFilter selectedVideoReactionFilter;
  final VideoReactionBloc videoReactionBloc;
  final ImageBloc imageBloc;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  VideoReactions({
    @required this.fixtureId,
    @required this.selectedVideoReactionFilter,
    @required this.videoReactionBloc,
    @required this.imageBloc,
  }) {
    _loadVideoReactions(page: 1);
  }

  void _loadVideoReactions({@required int page}) {
    videoReactionBloc.dispatchAction(
      LoadVideoReactions(
        fixtureId: fixtureId,
        filter: selectedVideoReactionFilter,
        page: page,
      ),
    );
  }

  List<Widget> build({
    @required BuildContext context,
    @required ThemeData theme,
    @required void Function(VideoReactionFilter) onChangeVideoReactionFilter,
    @required Future<bool> Function() onProtectedActionInvoked,
  }) {
    return [
      StreamBuilder<LoadVideoReactionsState>(
        initialData: VideoReactionsLoading(),
        stream: videoReactionBloc.videoReactionsState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          var disableButtons = state is VideoReactionsLoading;

          return SliverToBoxAdapter(
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
                                  _loadVideoReactions(page: 1);
                                }
                              : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.fiber_new),
                          onPressed: !disableButtons
                              ? () {
                                  selectedVideoReactionFilter =
                                      VideoReactionFilter.Newest;
                                  onChangeVideoReactionFilter(
                                    selectedVideoReactionFilter,
                                  );
                                  _loadVideoReactions(page: 1);
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
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: !disableButtons
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 8.0, 16.0, 8.0),
                              icon: Icon(
                                Icons.live_tv,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                bool canProceed =
                                    await onProtectedActionInvoked();
                                if (canProceed) {
                                  await Navigator.of(context).pushNamed(
                                    VideoReactionPage.routeName,
                                    arguments: fixtureId,
                                  );

                                  _loadVideoReactions(page: 1);
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
          if (state is VideoReactionsLoading) {
            return SliverToBoxAdapter(child: SizedBox.shrink());
          }

          var fixtureVideoReactions =
              (state as VideoReactionsReady).fixtureVideoReactions;
          var videoReactions = fixtureVideoReactions.videoReactions;

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var videoReaction = videoReactions[index];

                var action = GetVideoThumbnail(videoId: videoReaction.videoId);
                imageBloc.dispatchAction(action);

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
                  child: Stack(
                    children: [
                      Card(
                        color: _color,
                        elevation: 5.0,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 24.0,
                        ),
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 16.0 / 9.0,
                              child: Container(
                                width: double.infinity,
                                color: Colors.black87,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    FutureBuilder<GetVideoThumbnailState>(
                                      initialData: VideoThumbnailLoading(),
                                      future: action.state,
                                      builder: (context, snapshot) {
                                        var state = snapshot.data;
                                        if (state is VideoThumbnailLoading ||
                                            state is VideoThumbnailError) {
                                          return SizedBox.shrink();
                                        }

                                        var thumbnailFile =
                                            (state as VideoThumbnailReady)
                                                .thumbnailFile;

                                        return Image.file(
                                          thumbnailFile,
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          VideoPage.routeName,
                                          arguments: videoReaction.videoId,
                                        );
                                      },
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white54,
                                        size: 80.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 12.0, 8.0, 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      videoReaction.title,
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 12.0),
                                  Expanded(
                                    flex: 2,
                                    child: VideoReactionRating(
                                      fixtureId: fixtureId,
                                      videoReaction: videoReaction,
                                      onProtectedActionInvoked:
                                          onProtectedActionInvoked,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0.0,
                        left: 12.0,
                        child: Card(
                          color: const Color(0xff2b2d42),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: Text(
                              videoReaction.authorUsername,
                              style: GoogleFonts.patuaOne(
                                fontSize: 22.0,
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
              childCount: videoReactions.length,
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
          }

          var fixtureVideoReactions =
              (state as VideoReactionsReady).fixtureVideoReactions;

          int page = fixtureVideoReactions.page;
          int totalPages = fixtureVideoReactions.totalPages;

          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: _color,
              alignment: Alignment.bottomCenter,
              child: page < totalPages
                  ? IconButton(
                      onPressed: () => _loadVideoReactions(page: page + 1),
                      icon: Icon(Icons.more_horiz),
                    )
                  : null,
            ),
          );
        },
      ),
    ];
  }
}
