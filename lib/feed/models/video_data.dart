import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class VideoData {
  final bool isYoutubeVideo;
  final Uint8List thumbnailBytes;
  final String videoUrl;

  VideoData({
    @required this.isYoutubeVideo,
    @required this.thumbnailBytes,
    @required this.videoUrl,
  });
}
