import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../bloc/video_reaction_actions.dart';
import '../bloc/video_reaction_bloc.dart';
import '../../../../general/extensions/kiwi_extension.dart';

class VideoReactionPage extends StatefulWidget
    with DependencyResolver<VideoReactionBloc> {
  static const routeName = '/fixture/livescore/video-reaction';

  final int fixtureId;

  const VideoReactionPage({
    Key key,
    @required this.fixtureId,
  }) : super(key: key);

  @override
  _VideoReactionPageState createState() => _VideoReactionPageState(resolve());
}

class _VideoReactionPageState extends State<VideoReactionPage> {
  final VideoReactionBloc _videoReactionBloc;

  ImagePicker _imagePicker;
  ImagePicker get imagePicker {
    if (_imagePicker == null) {
      _imagePicker = ImagePicker();
    }
    return _imagePicker;
  }

  String _title;
  Uint8List _videoBytes;
  String _fileName;

  _VideoReactionPageState(this._videoReactionBloc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF398AE5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF398AE5),
        title: Text(
          'The 12th Player',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
            ),
          ),
        ),
        brightness: Brightness.dark,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(height: 24.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6CA8F1),
                    border: Border.all(
                      color: Colors.white,
                      width: 4.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6.0,
                        offset: const Offset(0.0, 2.0),
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    onChanged: (value) => _title = value,
                    style: GoogleFonts.openSans(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(top: 14.0),
                      prefixIcon: Icon(
                        Icons.text_fields,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 4.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () async {
                    var source = await showDialog<ImageSource>(
                      context: context,
                      builder: (context) => Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                child: Text('Gallery'),
                                onPressed: () => Navigator.of(context)
                                    .pop(ImageSource.gallery),
                              ),
                              SizedBox(height: 12.0),
                              ElevatedButton(
                                child: Text('Camera'),
                                onPressed: () => Navigator.of(context)
                                    .pop(ImageSource.camera),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    if (source == null) {
                      return;
                    }

                    try {
                      var pickedFile = await imagePicker.pickVideo(
                        source: source,
                        preferredCameraDevice: CameraDevice.front,
                        maxDuration: Duration(minutes: 5), // @@TODO: Config.
                      );

                      if (pickedFile != null) {
                        _videoBytes = await pickedFile.readAsBytes();
                        setState(() {
                          _fileName = basename(pickedFile.path);
                        });
                      }
                    } catch (_) {}
                  },
                  child: Icon(
                    Icons.videocam,
                    color: _videoBytes == null ? Colors.white : Colors.orange,
                    size: 120.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.upload_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          _videoReactionBloc.dispatchAction(
            PostVideoReaction(
              fixtureId: widget.fixtureId,
              title: _title,
              videoBytes: _videoBytes,
              fileName: _fileName,
            ),
          );

          setState(() {
            _title = null;
            _videoBytes = null;
            _fileName = null;
          });
        },
      ),
    );
  }
}
