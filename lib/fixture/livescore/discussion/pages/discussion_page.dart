import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../bloc/discussion_actions.dart';
import '../bloc/discussion_bloc.dart';
import '../bloc/discussion_states.dart';
import '../../../../general/bloc/image_actions.dart';
import '../../../../general/bloc/image_bloc.dart';
import '../../../../general/bloc/image_states.dart';
import '../../../../general/extensions/kiwi_extension.dart';

class DiscussionPage extends StatefulWidget {
  static const routeName = '/fixture/livescore/discussion';

  final int fixtureId;
  final String discussionId;

  const DiscussionPage({
    Key key,
    @required this.fixtureId,
    @required this.discussionId,
  }) : super(key: key);

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState
    extends StateWith2<DiscussionPage, DiscussionBloc, ImageBloc> {
  DiscussionBloc get _discussionBloc => service1;
  ImageBloc get _imageBloc => service2;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _bodyController = TextEditingController();
  final SnappingSheetController _sheetController = SnappingSheetController();

  bool _firstBuild = true;

  String _body;

  @override
  void initState() {
    super.initState();

    _discussionBloc.dispatchAction(
      LoadDiscussion(
        fixtureId: widget.fixtureId,
        discussionId: widget.discussionId,
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
        discussionId: widget.discussionId,
      ),
    );

    _scrollController.dispose();
    _bodyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width * 0.25 - 27.0;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 241, 246, 1.0),
      appBar: AppBar(
        backgroundColor: const Color(0xff023e8a),
        title: Text(
          'The 12th Player',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SnappingSheet(
        snappingSheetController: _sheetController,
        snapPositions: const [
          SnapPosition(
            positionPixel: 0.0,
            snappingCurve: Curves.elasticOut,
            snappingDuration: Duration(milliseconds: 500),
          ),
          SnapPosition(positionPixel: 100.0),
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
            StreamBuilder<LoadDiscussionState>(
              initialData: DiscussionLoading(),
              stream: _discussionBloc.discussionState$,
              builder: (context, snapshot) {
                var state = snapshot.data;
                if (state is DiscussionLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is DiscussionError) {
                  return SizedBox.shrink();
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
                      discussionId: widget.discussionId,
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

                            return Table(
                              columnWidths: const <int, TableColumnWidth>{
                                0: IntrinsicColumnWidth(),
                                1: FlexColumnWidth(),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Container(height: 40.0),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Card(
                                        color: entry.color,
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12.0),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 8.0,
                                          ),
                                          child: Text(
                                            entry.username,
                                            style: GoogleFonts.patuaOne(
                                              fontSize: 20.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          15.0, 4.0, 12.0, 4.0),
                                      width: width,
                                      height: width * 16.0 / 9.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child:
                                          FutureBuilder<GetProfileImageState>(
                                        initialData: ProfileImageLoading(),
                                        future: action.state,
                                        builder: (context, snapshot) {
                                          var state = snapshot.data;
                                          if (state is ProfileImageLoading) {
                                            return Image.asset(
                                              'assets/images/dummy_profile_image.png',
                                              fit: BoxFit.cover,
                                            );
                                          }

                                          var imageFile =
                                              (state as ProfileImageReady)
                                                  .imageFile;

                                          return Image.file(
                                            imageFile,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: width * 16.0 / 9.0,
                                        ),
                                        child: Card(
                                          elevation: 5.0,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color: entry.color,
                                              width: 2.0,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(12.0),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14.0,
                                              vertical: 12.0,
                                            ),
                                            child: Text(
                                              entry.body,
                                              style:
                                                  GoogleFonts.signikaNegative(
                                                fontSize: 20.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        grabbingHeight: 50.0,
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
            children: [
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
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
        sheetBelow: SnappingSheetContent(
          heightBehavior: SnappingSheetHeight.fixed(),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: _bodyController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 16.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      labelText: 'Share your thoughts',
                      labelStyle: GoogleFonts.exo2(
                        textStyle: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    maxLines: 3,
                    onChanged: (value) => _body = value,
                  ),
                ),
                Expanded(
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(
                      Icons.upload_rounded,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    mini: true,
                    onPressed: () async {
                      var action = PostDiscussionEntry(
                        fixtureId: widget.fixtureId,
                        discussionId: widget.discussionId,
                        body: _body,
                      );
                      _discussionBloc.dispatchAction(action);

                      var state = await action.state;
                      if (state is DiscussionEntryPostingSucceeded) {
                        _bodyController.clear();
                        _body = null;

                        if (_sheetController.currentSnapPosition !=
                            _sheetController.snapPositions.first) {
                          _sheetController.snapToPosition(
                            _sheetController.snapPositions.first,
                          );
                        }
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
