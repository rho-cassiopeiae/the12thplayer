import 'dart:io';
import 'dart:typed_data';

import 'package:tuple/tuple.dart';

abstract class IImageService {
  Future<File> getProfileImage(String username);

  Future<List<int>> resizeImage(File imageFile, {int dimension = 100});

  Future<Tuple2<List<int>, String>> compressImage(
    Uint8List imageBytes,
    int maxSizeBytes,
  );

  Future<void> invalidateCachedProfileImage(String username);
}
