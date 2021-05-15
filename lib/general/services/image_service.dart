import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';

import '../interfaces/iimage_service.dart';
import '../errors/error.dart';

class ImageService implements IImageService {
  final String profileImageUrlPrefix =
      FlutterConfig.get('PROFILE_IMAGE_URL_PREFIX');

  Completer<Tuple2<File, Uint8List>> _dummyProfileImageLoaded;

  Future<Tuple2<File, Uint8List>> _loadDummyProfileImage() async {
    if (_dummyProfileImageLoaded == null) {
      _dummyProfileImageLoaded = Completer<Tuple2<File, Uint8List>>();

      var dummyProfileImageByteData = await rootBundle.load(
        'assets/images/dummy_profile_image.png',
      );
      var dummyProfileImageBytes = dummyProfileImageByteData.buffer.asUint8List(
        dummyProfileImageByteData.offsetInBytes,
        dummyProfileImageByteData.lengthInBytes,
      );
      var dummyProfileImage = File(
        '${(await getTemporaryDirectory()).path}/dummy_profile_image.png',
      );

      await dummyProfileImage.writeAsBytes(dummyProfileImageBytes);

      _dummyProfileImageLoaded.complete(
        Tuple2(dummyProfileImage, dummyProfileImageBytes),
      );
    }

    return _dummyProfileImageLoaded.future;
  }

  Future<File> getProfileImage(String username) async {
    var cacheManager = DefaultCacheManager();
    var url = '$profileImageUrlPrefix/$username.png';
    try {
      var cachedImage = await cacheManager.getFileFromCache(url);
      if (cachedImage != null &&
          cachedImage.validTill.isAfter(DateTime.now())) {
        return cachedImage.file;
      }

      return (await cacheManager.downloadFile(url)).file;
    } catch (error) {
      print('===== $error =====');

      var result = await _loadDummyProfileImage();

      await cacheManager.putFile(
        url,
        result.item2,
        eTag: 'doesn\'t matter',
        maxAge: Duration(days: 1),
        fileExtension: 'png',
      );

      return result.item1;
    }
  }

  Future<List<int>> resizeImage(File imageFile, {int dimension = 100}) async {
    // @@TODO: Background isolate ?
    var image = decodeImage(await imageFile.readAsBytes());
    image = copyResize(
      image,
      width: image.height > image.width ? null : dimension,
      height: image.width > image.height ? null : dimension,
    );

    return encodePng(image);
  }

  Future<Tuple2<List<int>, String>> compressImage(
    Uint8List imageBytes,
    int maxSizeBytes,
  ) async {
    // @@TODO: Background isolate ?
    String imageFormat;
    var decoder = findDecoderForData(imageBytes);
    if (decoder != null) {
      if (decoder is JpegDecoder) {
        imageFormat = 'jpg';
      } else if (decoder is PngDecoder) {
        imageFormat = 'png';
      }
    }

    if (imageFormat == null) {
      throw Error('Unsupported image format');
    }

    var image = decoder.decodeImage(imageBytes);

    List<int> compressedImageBytes;
    if (imageFormat == 'jpg') {
      var targetQuality = int.parse(
        FlutterConfig.get('IMAGE_COMPRESSION_TARGET_QUALITY'),
      );
      do {
        compressedImageBytes = encodeJpg(image, quality: targetQuality);
      } while (compressedImageBytes.length > maxSizeBytes &&
          (targetQuality ~/= 2) > 0);
    } else {
      compressedImageBytes = encodePng(image, level: 9);
    }

    if (compressedImageBytes.length > imageBytes.length) {
      compressedImageBytes = imageBytes;
    }

    if (compressedImageBytes.length > maxSizeBytes) {
      throw Error(
        'The image is too big and cannot be compressed sufficiently',
      );
    }

    return Tuple2(compressedImageBytes, imageFormat);
  }

  Future<void> invalidateCachedProfileImage(String username) =>
      DefaultCacheManager().removeFile('$profileImageUrlPrefix/$username.png');
}
