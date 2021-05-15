import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../../icons/football.dart';
import '../bloc/live_commentary_recording_actions.dart';
import '../bloc/live_commentary_recording_bloc.dart';
import '../bloc/live_commentary_recording_states.dart';
import '../enums/live_commentary_recording_entry_status.dart';
import '../enums/live_commentary_recording_status.dart';
import '../../../../general/extensions/color_extension.dart';
import '../../../../general/extensions/kiwi_extension.dart';

class LiveCommentaryRecordingPage extends StatefulWidget
    with DependencyResolver<LiveCommentaryRecordingBloc> {
  static const String routeName =
      '/fixture/livescore/live-commentary-recording';

  final int fixtureId;
  final int teamId;

  const LiveCommentaryRecordingPage({
    Key key,
    @required this.fixtureId,
    @required this.teamId,
  }) : super(key: key);

  @override
  _LiveCommentaryRecordingPageState createState() =>
      _LiveCommentaryRecordingPageState(
        resolve('fixture:$fixtureId.team:$teamId.live-commentary-recording'),
      );
}

class _LiveCommentaryRecordingPageState
    extends State<LiveCommentaryRecordingPage> {
  final LiveCommentaryRecordingBloc _liveCommentaryRecordingBloc;

  ImagePicker _imagePicker;
  ImagePicker get imagePicker {
    if (_imagePicker == null) {
      _imagePicker = ImagePicker();
    }
    return _imagePicker;
  }

  final SnappingSheetController _sheetController = SnappingSheetController();

  final TextEditingController _minController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  final FocusNode _hiddenFocusNode = FocusNode();
  final FocusNode _minFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _commentFocusNode = FocusNode();

  final Map<String, Icon> _eventToIcon = {
    'Goal': Icon(
      Football.football_ball_variant_1,
      color: Colors.purple[800],
      size: 28,
    ),
    'Yellow card': Icon(
      Football.football_card_with_cross_mark,
      color: Colors.yellow[800],
      size: 28,
    ),
    'Red card': Icon(
      Football.football_card_with_cross_mark,
      color: Colors.red[800],
      size: 28,
    ),
    'Sub': Icon(
      Icons.swap_horizontal_circle_outlined,
      color: Colors.black,
      size: 28,
    ),
  };

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  String _selectedEvent = 'Goal';

  String _min;
  String _title;
  String _body;
  Uint8List _imageBytes;

  String _name;

  _LiveCommentaryRecordingPageState(this._liveCommentaryRecordingBloc);

  @override
  void initState() {
    super.initState();
    _liveCommentaryRecordingBloc.dispatchAction(
      LoadLiveCommentaryRecording(fixtureId: widget.fixtureId),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _titleController.dispose();
    _commentController.dispose();

    _hiddenFocusNode.dispose();
    _minFocusNode.dispose();
    _titleFocusNode.dispose();
    _commentFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _color,
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
          SnapPosition(positionPixel: 172),
          SnapPosition(positionPixel: 244),
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
            StreamBuilder<LiveCommentaryRecordingEntriesState>(
              initialData: LiveCommentaryRecordingEntriesLoading(),
              stream: _liveCommentaryRecordingBloc.entriesState$,
              builder: (context, snapshot) {
                var state = snapshot.data;
                if (state is LiveCommentaryRecordingEntriesLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is LiveCommentaryRecordingEntriesError) {
                  return Center(child: Text(state.message));
                }

                var entries =
                    (state as LiveCommentaryRecordingEntriesReady).entries;
                return CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var entry = entries[index];
                          return Container(
                            margin: index == entries.length - 1
                                ? const EdgeInsets.only(bottom: 60)
                                : null,
                            child: Stack(
                              children: [
                                Card(
                                  color: _color,
                                  elevation: 8,
                                  margin:
                                      const EdgeInsets.fromLTRB(53, 12, 12, 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Icon(
                                                entry.icon != null
                                                    ? _eventToIcon[entry.icon]
                                                        .icon
                                                    : Icons.ac_unit,
                                                size: 30,
                                                color: entry.icon != null
                                                    ? _eventToIcon[entry.icon]
                                                        .color
                                                    : _color,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Text(
                                                entry.title ?? '',
                                                style: GoogleFonts.exo2(
                                                  textStyle: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Spacer(),
                                          ],
                                        ),
                                        if (entry.icon != null ||
                                            entry.title != null)
                                          SizedBox(height: 16),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                entry.body ?? '',
                                                style: GoogleFonts.exo2(
                                                  textStyle: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (entry.imagePath != null)
                                              InkWell(
                                                onLongPress: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => Dialog(
                                                      child: Container(
                                                        width: size.width * 0.7,
                                                        height:
                                                            size.height * 0.7,
                                                        color: Colors.black87,
                                                        child: Image.file(
                                                          File(entry.imagePath),
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: size.width / 6,
                                                  height: size.height / 6,
                                                  margin: const EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(12),
                                                    ),
                                                  ),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Image.file(
                                                    File(entry.imagePath),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (entry.status ==
                                    LiveCommentaryRecordingEntryStatus
                                        .Publishing)
                                  Positioned(
                                    right: 16,
                                    top: 16,
                                    child: Icon(Icons.upload_outlined),
                                  ),
                                if (entry.status ==
                                    LiveCommentaryRecordingEntryStatus
                                        .Published)
                                  Positioned(
                                    right: 16,
                                    top: 16,
                                    child: Icon(
                                      Icons.done_outline_rounded,
                                      color: Colors.green,
                                    ),
                                  ),
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  width: 50,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 15,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              index == entries.length - 1
                                                  ? BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(7.5),
                                                      bottomRight:
                                                          Radius.circular(7.5),
                                                    )
                                                  : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black87,
                                              blurRadius: 0.0,
                                              spreadRadius: 0.0,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (entry.time != null)
                                        CircleAvatar(
                                          backgroundColor: Colors.black87,
                                          radius: 22,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 2.0,
                                            ),
                                            child: FittedBox(
                                              child: Text(
                                                entry.time,
                                                style: GoogleFonts.lexendMega(
                                                  textStyle: TextStyle(
                                                    color: _color,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  Container(
                    width: 100.0,
                    height: 10.0,
                    margin: EdgeInsets.only(top: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(top: 8.0, right: 20.0),
                        child: FittedBox(
                          child: StreamBuilder<
                              LiveCommentaryRecordingPublishButtonState>(
                            initialData:
                                LiveCommentaryRecordingPublishButtonLoading(),
                            stream: _liveCommentaryRecordingBloc
                                .publishButtonState$,
                            builder: (context, snapshot) {
                              var state = snapshot.data;
                              if (state
                                  is LiveCommentaryRecordingPublishButtonLoading) {
                                return CircularProgressIndicator();
                              }

                              return FloatingActionButton(
                                backgroundColor: state
                                        is LiveCommentaryRecordingPublishButtonActive
                                    ? Colors.red[400]
                                    : Colors.grey[600],
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 34,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _liveCommentaryRecordingBloc.dispatchAction(
                                    ToggleLiveCommentaryRecordingPublishMode(
                                      fixtureId: widget.fixtureId,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _minController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            labelText: 'Min',
                          ),
                          focusNode: _minFocusNode,
                          onChanged: (value) => _min = value,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: _eventToIcon[_selectedEvent],
                          onPressed: () async {
                            bool hasFocus;
                            FocusNode focusedChild;
                            var selectedEvent = await showDialog<String>(
                              context: context,
                              builder: (ctx) {
                                var focusScope = FocusScope.of(context);
                                hasFocus = focusScope.hasFocus;
                                focusedChild = focusScope.focusedChild;

                                var hiddenFocus = hasFocus &&
                                        focusedChild != null &&
                                        MediaQuery.of(ctx).viewInsets.bottom > 0
                                    ? _hiddenFocusNode
                                    : null;

                                if (hiddenFocus != null) {
                                  focusScope.requestFocus(hiddenFocus);
                                }

                                return Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: _eventToIcon['Goal'],
                                          onPressed: () {
                                            Navigator.of(ctx).pop('Goal');
                                          },
                                        ),
                                        IconButton(
                                          icon: _eventToIcon['Yellow card'],
                                          onPressed: () {
                                            Navigator.of(ctx).pop(
                                              'Yellow card',
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: _eventToIcon['Red card'],
                                          onPressed: () {
                                            Navigator.of(ctx).pop('Red card');
                                          },
                                        ),
                                        IconButton(
                                          icon: _eventToIcon['Sub'],
                                          onPressed: () {
                                            Navigator.of(ctx).pop('Sub');
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            if (hasFocus && focusedChild != null) {
                              FocusScope.of(context).requestFocus(
                                focusedChild,
                              );
                            }

                            if (selectedEvent != null) {
                              setState(() {
                                _selectedEvent = selectedEvent;
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            labelText: 'Title',
                          ),
                          focusNode: _titleFocusNode,
                          onChanged: (value) => _title = value,
                        ),
                      ),
                      SizedBox(
                        height: 0,
                        width: 0,
                        child: TextField(
                          focusNode: _hiddenFocusNode,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
                          icon: Icon(
                            Icons.image,
                            color: _imageBytes != null ? Colors.orange : null,
                          ),
                          onPressed: () async {
                            var currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }

                            var source = await showDialog<ImageSource>(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          child: Text('Gallery'),
                                          onPressed: () => Navigator.of(context)
                                              .pop(ImageSource.gallery),
                                        ),
                                        SizedBox(height: 12),
                                        ElevatedButton(
                                          child: Text('Camera'),
                                          onPressed: () => Navigator.of(context)
                                              .pop(ImageSource.camera),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            if (source == null) {
                              return;
                            }

                            var pickedImage = await imagePicker.getImage(
                              source: source,
                            );
                            if (pickedImage != null) {
                              var imageBytes = await pickedImage.readAsBytes();
                              setState(() {
                                _imageBytes = imageBytes;
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            labelText: 'Comment',
                          ),
                          focusNode: _commentFocusNode,
                          maxLines: 3,
                          onChanged: (value) => _body = value,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          icon: Icon(Icons.upload_rounded),
                          onPressed: () async {
                            var action = PostLiveCommentaryRecordingEntry(
                              fixtureId: widget.fixtureId,
                              time: _min,
                              icon: _selectedEvent,
                              title: _title,
                              body: _body,
                              imageBytes: _imageBytes,
                            );

                            _liveCommentaryRecordingBloc.dispatchAction(action);
                            await action.state; // @@TODO: Handle error.

                            _minController.clear();
                            _titleController.clear();
                            _commentController.clear();

                            setState(() {
                              _min = null;
                              _selectedEvent = 'Goal';
                              _title = null;
                              _body = null;
                              _imageBytes = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<LiveCommentaryRecordingNameState>(
                  initialData: LiveCommentaryRecordingNameLoading(),
                  stream: _liveCommentaryRecordingBloc.nameState$,
                  builder: (context, snapshot) {
                    var state = snapshot.data;
                    if (state is LiveCommentaryRecordingNameLoading ||
                        state is LiveCommentaryRecordingNameError) {
                      return CircularProgressIndicator();
                    }

                    var readyState =
                        (state as LiveCommentaryRecordingNameReady);
                    return Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: readyState.creationStatus ==
                                  LiveCommentaryRecordingStatus.None
                              ? TextField(
                                  onChanged: (value) => _name = value,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(10.0),
                                    hintText: readyState.name,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                )
                              : Text(readyState.name),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            child: Text('OK'),
                            onPressed: readyState.creationStatus ==
                                    LiveCommentaryRecordingStatus.None
                                ? () async {
                                    var action = RenameLiveCommentaryRecording(
                                      fixtureId: widget.fixtureId,
                                      name: _name,
                                    );
                                    _liveCommentaryRecordingBloc
                                        .dispatchAction(action);

                                    await action.state; // @@TODO: Handle error.
                                  }
                                : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
