import 'package:flutter/foundation.dart';

import '../models/video_data.dart';

abstract class FeedState {}

abstract class ProcessVideoUrlState extends FeedState {}

class ProcessVideoUrlReady extends ProcessVideoUrlState {
  final VideoData videoData;

  ProcessVideoUrlReady({@required this.videoData});
}

class ProcessVideoUrlError extends ProcessVideoUrlState {}
