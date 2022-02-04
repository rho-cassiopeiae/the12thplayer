import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/link_dialog.dart';
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
              aspectRatio: 16.0 / 9.0,
              child: Container(
                decoration: BoxDecoration(
                  border: _thumbnailBytes == null
                      ? Border.all(
                          color: Colors.white,
                          width: 4.0,
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
                            builder: (_) => const LinkDialog(),
                          );

                          if (url == null) {
                            return;
                          }

                          var action = ProcessVideoUrl(url: url);
                          _feedBloc.dispatchAction(action);

                          var state = await action.state;
                          if (state is VideoUrlProcessingSucceeded) {
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
                          size: 120.0,
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
                              size: 80.0,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    onChanged: (value) => _summary = value,
                    minLines: 3,
                    maxLines: 3,
                    maxLength: 110, // @@TODO: Config.
                    style: GoogleFonts.openSans(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.fromLTRB(16.0, 14.0, 4.0, 0.0),
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
          if (state is ArticlePostingSucceeded) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
      ),
    );
  }
}
