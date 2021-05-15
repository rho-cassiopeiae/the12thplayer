import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../bloc/discussion_actions.dart';
import '../bloc/discussion_bloc.dart';
import '../bloc/discussion_states.dart';
import '../../../../general/bloc/image_actions.dart';
import '../../../../general/bloc/image_bloc.dart';
import '../../../../general/bloc/image_states.dart';
import '../../../../general/extensions/color_extension.dart';
import '../../../../general/extensions/kiwi_extension.dart';

class DiscussionPage extends StatefulWidget
    with DependencyResolver2<DiscussionBloc, ImageBloc> {
  static const routeName = '/fixture/livescore/discussion';

  final int fixtureId;
  final String discussionIdentifier;

  const DiscussionPage({
    Key key,
    @required this.fixtureId,
    @required this.discussionIdentifier,
  }) : super(key: key);

  @override
  _DiscussionPageState createState() =>
      _DiscussionPageState(resolve1(), resolve2());
}

class _DiscussionPageState extends State<DiscussionPage> {
  final DiscussionBloc _discussionBloc;
  final ImageBloc _imageBloc;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _bodyController = TextEditingController();
  final SnappingSheetController _sheetController = SnappingSheetController();

  bool _firstBuild = true;

  String _body;

  _DiscussionPageState(this._discussionBloc, this._imageBloc);

  @override
  void initState() {
    super.initState();
    _discussionBloc.dispatchAction(
      LoadDiscussion(
        fixtureId: widget.fixtureId,
        discussionIdentifier: widget.discussionIdentifier,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant DiscussionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _firstBuild = true;
  }

  @override
  void dispose() {
    _discussionBloc.dispose(
      cleanupAction: UnsubscribeFromDiscussion(
        fixtureId: widget.fixtureId,
        discussionIdentifier: widget.discussionIdentifier,
      ),
    );

    _scrollController.dispose();
    _bodyController.dispose();

    super.dispose();
  }

  Color _computeFontColor(Color color) {
    var luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 241, 246, 1.0),
      appBar: AppBar(
        backgroundColor: HexColor.fromHex('023e8a'),
        title: Text(
          'The 12th Player',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SnappingSheet(
        snappingSheetController: _sheetController,
        snapPositions: const [
          SnapPosition(
            positionPixel: 0.0,
            snappingCurve: Curves.elasticOut,
            snappingDuration: Duration(milliseconds: 500),
          ),
          SnapPosition(positionPixel: 100),
        ],
        onSnapEnd: () {
          if (_sheetController.currentSnapPosition ==
              _sheetController.snapPositions.first) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          }
        },
        child: Stack(
          children: [
            StreamBuilder<DiscussionState>(
              initialData: DiscussionLoading(),
              stream: _discussionBloc.state$,
              builder: (context, snapshot) {
                var state = snapshot.data;
                if (state is DiscussionLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is DiscussionError) {
                  return Center(child: Text(state.message));
                }

                var entries = (state as DiscussionReady).entries;
                bool moreEntriesToCome =
                    entries.isNotEmpty && !entries.first.isRootEntry;

                if (_firstBuild) {
                  _firstBuild = false;
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  });
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (!moreEntriesToCome) {
                      await Future.delayed(Duration(milliseconds: 300));
                      return;
                    }

                    var action = LoadMoreDiscussionEntries(
                      fixtureId: widget.fixtureId,
                      discussionIdentifier: widget.discussionIdentifier,
                      lastReceivedEntryId: entries.first.id,
                    );
                    _discussionBloc.dispatchAction(action);

                    await action.state;
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            var entry = entries[index];

                            var action = GetProfileImage(
                              username: entry.username,
                            );
                            _imageBloc.dispatchAction(action);

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 60,
                                        child: Text(
                                          entry.username,
                                          style: GoogleFonts.righteous(),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      FutureBuilder<ImageState>(
                                        initialData: ImageLoading(),
                                        future: action.state,
                                        builder: (context, snapshot) {
                                          var state = snapshot.data;
                                          if (state is ImageLoading) {
                                            return CircleAvatar(
                                              radius: 30,
                                              child: Text(
                                                entry.username
                                                    .substring(0, 2)
                                                    .toUpperCase(),
                                              ),
                                            );
                                          }

                                          var imageFile =
                                              (state as ImageReady).imageFile;
                                          return CircleAvatar(
                                            radius: 30,
                                            backgroundImage:
                                                FileImage(imageFile),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 12),
                                  Flexible(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: entry.color,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        entry.body,
                                        style: GoogleFonts.exo2(
                                          textStyle: TextStyle(
                                            color: _computeFontColor(
                                              entry.color,
                                            ),
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: entries.length,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            GestureDetector(
              child: Container(),
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (_sheetController.currentSnapPosition !=
                    _sheetController.snapPositions.first) {
                  _sheetController.snapToPosition(
                    _sheetController.snapPositions.first,
                  );
                }
              },
            ),
          ],
        ),
        grabbingHeight: 50,
        grabbing: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20.0,
                color: Colors.black.withOpacity(0.2),
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 100.0,
                height: 10.0,
                margin: const EdgeInsets.only(top: 15.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
              Container(
                height: 2.0,
                margin: EdgeInsets.only(left: 20, right: 20),
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
        sheetBelow: SnappingSheetContent(
          heightBehavior: SnappingSheetHeight.fixed(),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: _bodyController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      labelText: 'Share your thoughts',
                      labelStyle: GoogleFonts.exo2(
                        textStyle: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    maxLines: 3,
                    onChanged: (value) => _body = value,
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.upload_rounded),
                    onPressed: () async {
                      var action = PostDiscussionEntry(
                        fixtureId: widget.fixtureId,
                        discussionIdentifier: widget.discussionIdentifier,
                        body: _body,
                      );
                      _discussionBloc.dispatchAction(action);

                      await action.state; // @@TODO: Handle error.

                      _bodyController.clear();
                      _body = null;

                      if (_sheetController.currentSnapPosition !=
                          _sheetController.snapPositions.first) {
                        _sheetController.snapToPosition(
                          _sheetController.snapPositions.first,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
