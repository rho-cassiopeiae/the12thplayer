import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class VideoDataVm {
  final bool isYoutubeVideo;
  final Uint8List thumbnailBytes;
  final String videoUrl;

  VideoDataVm({
    @required this.isYoutubeVideo,
    @required this.thumbnailBytes,
    @required this.videoUrl,
  });
}
