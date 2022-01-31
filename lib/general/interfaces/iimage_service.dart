import 'dart:io';
import 'dart:typed_data';

import 'package:either_option/either_option.dart';
import 'package:tuple/tuple.dart';

import '../errors/error.dart';

abstract class IImageService {
  Future<File> getProfileImage(String username);

  Future<Either<Error, File>> getVideoThumbnail(String videoId);

  Future<List<int>> resizeImage(File imageFile, {int dimension = 100});

  Future<Tuple2<List<int>, String>> compressImage(
    Uint8List imageBytes,
    int maxSizeBytes,
  );

  Future<void> invalidateCachedProfileImage(String username);

  Future<File> downloadImage(String url);
}
