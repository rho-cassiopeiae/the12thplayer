abstract class IVimeoApiService {
  Future<Map<String, String>> getVideoQualityUrls(String videoId);
}
