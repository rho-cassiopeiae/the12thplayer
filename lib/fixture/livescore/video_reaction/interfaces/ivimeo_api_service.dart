abstract class IVimeoApiService {
  Future<String> getVideoThumbnailUrl(String videoId);
  Future<Map<String, String>> getVideoQualityUrls(String videoId);
}
