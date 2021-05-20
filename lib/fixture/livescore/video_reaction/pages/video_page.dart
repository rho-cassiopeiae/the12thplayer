import 'package:flutter/material.dart';
import 'package:vimeoplayer/vimeoplayer.dart';

class VideoPage extends StatelessWidget {
  static const routeName = '/fixture/livescore/video';

  final String videoId;

  const VideoPage({Key key, @required this.videoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87.withOpacity(0.6),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VimeoPlayer(
            id: videoId,
            autoPlay: true,
          ),
        ],
      ),
    );
  }
}
