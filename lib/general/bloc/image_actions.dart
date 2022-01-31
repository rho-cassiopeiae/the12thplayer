import 'package:flutter/foundation.dart';

import 'mixins.dart';
import 'image_states.dart';

abstract class ImageAction {}

abstract class ImageActionAwaitable<T extends ImageState> extends ImageAction
    with AwaitableState<T> {}

class GetProfileImage extends ImageActionAwaitable<GetProfileImageState> {
  final String username;

  GetProfileImage({@required this.username});
}

class GetVideoThumbnail extends ImageActionAwaitable<GetVideoThumbnailState> {
  final String videoId;

  GetVideoThumbnail({@required this.videoId});
}
