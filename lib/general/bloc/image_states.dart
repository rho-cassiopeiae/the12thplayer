import 'dart:io';

import 'package:flutter/foundation.dart';

abstract class ImageState {}

class ImageLoading extends ImageState {}

class ImageReady extends ImageState {
  final File imageFile;

  ImageReady({@required this.imageFile});
}
