import 'image_states.dart';
import '../interfaces/iimage_service.dart';
import 'image_actions.dart';
import 'bloc.dart';

class ImageBloc extends Bloc<ImageAction> {
  final IImageService _imageService;

  ImageBloc(this._imageService) {
    actionChannel.stream.listen((action) {
      if (action is GetProfileImage) {
        _getProfileImage(action);
      } else if (action is GetVideoThumbnail) {
        _getVideoThumbnail(action);
      }
    });
  }

  @override
  void dispose({ImageAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
  }

  void _getProfileImage(GetProfileImage action) async {
    var image = await _imageService.getProfileImage(action.username);
    action.complete(ProfileImageReady(imageFile: image));
  }

  void _getVideoThumbnail(GetVideoThumbnail action) async {
    var result = await _imageService.getVideoThumbnail(action.videoId);

    var state = result.fold(
      (error) => VideoThumbnailError(),
      (file) => VideoThumbnailReady(thumbnailFile: file),
    );

    action.complete(state);
  }
}
