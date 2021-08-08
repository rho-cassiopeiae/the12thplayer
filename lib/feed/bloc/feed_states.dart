import 'package:flutter/foundation.dart';

import '../models/video_data.dart';

abstract class FeedState {}

abstract class ProcessVideoUrlState extends FeedState {}

class ProcessVideoUrlReady extends ProcessVideoUrlState {
  final VideoData videoData;

  ProcessVideoUrlReady({@required this.videoData});
}

class ProcessVideoUrlError extends ProcessVideoUrlState {}

abstract class SaveArticlePreviewState extends FeedState {}

class SaveArticlePreviewReady extends SaveArticlePreviewState {}

class SaveArticlePreviewError extends SaveArticlePreviewState {}

class SaveArticleReady extends FeedState {}

abstract class PostArticleState extends FeedState {}

class PostArticleReady extends PostArticleState {}

class PostArticleError extends PostArticleState {}
