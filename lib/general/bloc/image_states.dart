import 'dart:io';

import 'package:flutter/foundation.dart';

abstract class ImageState {}

abstract class GetProfileImageState extends ImageState {}

class ProfileImageLoading extends GetProfileImageState {}

class ProfileImageReady extends GetProfileImageState {
  final File imageFile;

  ProfileImageReady({@required this.imageFile});
}

abstract class GetVideoThumbnailState extends ImageState {}

class VideoThumbnailLoading extends GetVideoThumbnailState {}

class VideoThumbnailReady extends GetVideoThumbnailState {
  final File thumbnailFile;

  VideoThumbnailReady({@required this.thumbnailFile});
}

class VideoThumbnailError extends GetVideoThumbnailState {}
