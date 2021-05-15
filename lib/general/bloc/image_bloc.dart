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
    action.complete(ImageReady(imageFile: image));
  }
}
