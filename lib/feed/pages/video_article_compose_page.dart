import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'youtube_video_page.dart';
import '../bloc/feed_actions.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_states.dart';
import '../enums/article_type.dart';
import '../../general/extensions/kiwi_extension.dart';

class VideoArticleComposePage extends StatefulWidget
    with DependencyResolver<FeedBloc> {
  static const routeName = '/feed/video-article-compose';

  final ArticleType type;

  const VideoArticleComposePage({
    Key key,
    @required this.type,
  }) : super(key: key);

  @override
  _VideoArticleComposePageState createState() =>
      _VideoArticleComposePageState(resolve());
}

class _VideoArticleComposePageState extends State<VideoArticleComposePage> {
  final FeedBloc _feedBloc;

  String _title;
  String _summary;

  bool _isYoutubeVideo;
  Uint8List _thumbnailBytes;
  String _videoUrl;

  _VideoArticleComposePageState(this._feedBloc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF398AE5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF398AE5),
        title: Text(
          'The12thPlayer',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
        brightness: Brightness.dark,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6.0,
                        offset: const Offset(0, 2),
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
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  border: _thumbnailBytes == null
                      ? Border.all(
                          color: Colors.white,
                          width: 4,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: _thumbnailBytes == null
                    ? InkWell(
                        onTap: () async {
                          var url = await showDialog<String>(
                            context: context,
                            builder: (_) => const _LinkDialog(),
                          );

                          if (url == null) {
                            return;
                          }

                          var action = ProcessVideoUrl(url: url);
                          _feedBloc.dispatchAction(action);

                          var state = await action.state;
                          if (state is ProcessVideoUrlReady) {
                            setState(() {
                              _isYoutubeVideo = state.videoData.isYoutubeVideo;
                              _thumbnailBytes = state.videoData.thumbnailBytes;
                              _videoUrl = state.videoData.videoUrl;
                            });
                          }
                        },
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: 120,
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            _thumbnailBytes,
                            fit: BoxFit.cover,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_isYoutubeVideo) {
                                Navigator.of(context).pushNamed(
                                  YoutubeVideoPage.routeName,
                                  arguments: _videoUrl,
                                );
                              }
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
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Summary',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6CA8F1),
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    onChanged: (value) => _summary = value,
                    minLines: 3,
                    maxLines: 3,
                    maxLength: 110,
                    style: GoogleFonts.openSans(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(16, 14, 4, 0),
                    ),
                  ),
                ),
              ],
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
        onPressed: () async {
          var action = PostVideoArticle(
            type: widget.type,
            title: _title,
            thumbnailBytes: _thumbnailBytes,
            videoUrl: _videoUrl,
            summary: _summary,
          );
          _feedBloc.dispatchAction(action);

          var state = await action.state;
        },
      ),
    );
  }
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({Key key}) : super(key: key);

  @override
  _LinkDialogState createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  String _link = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        decoration: const InputDecoration(labelText: 'Paste a link'),
        autofocus: true,
        onChanged: _linkChanged,
      ),
      actions: [
        TextButton(
          onPressed: _link.isNotEmpty ? _applyLink : null,
          child: const Text('Ok'),
        ),
      ],
    );
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  void _applyLink() {
    Navigator.pop(context, _link);
  }
}
