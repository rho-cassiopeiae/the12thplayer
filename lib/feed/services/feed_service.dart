import 'package:either_option/either_option.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/video_data.dart';
import '../../general/interfaces/iimage_service.dart';
import '../../general/services/notification_service.dart';
import '../interfaces/ifeed_api_service.dart';
import '../models/vm/article_vm.dart';
import '../../general/persistence/storage.dart';
import '../../general/errors/error.dart';

class FeedService {
  final Storage _storage;
  final NotificationService _notificationService;
  final IFeedApiService _feedApiService;
  final IImageService _imageService;

  FeedService(
    this._storage,
    this._notificationService,
    this._feedApiService,
    this._imageService,
  );

  Stream<Either<Error, List<ArticleVm>>> subscribeToFeed() async* {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      _storage.clearTeamFeedArticles();

      await for (var update
          in await _feedApiService.subscribeToTeamFeed(currentTeam.id)) {
        var articles = update.articles
            .map((article) => ArticleVm.fromDto(article))
            .toList();

        _storage.addTeamFeedArticles(articles);

        yield Right(_storage.getTeamFeedArticles());
      }
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      yield Left(Error(error.toString()));
    }
  }

  Future<VideoData> processVideoUrl(String url) async {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      var videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        try {
          // @@TODO: Try multiple thumbnail urls.
          var thumbnail = await _imageService.downloadImage(
            'https://i.ytimg.com/vi/$videoId/mqdefault.jpg',
          );

          return VideoData(
            isYoutubeVideo: true,
            thumbnailBytes: await thumbnail.readAsBytes(),
            videoUrl: url,
          );
        } catch (error, stackTrace) {
          print('===== $error =====');
          print(stackTrace);

          _notificationService.showMessage(error.toString());
        }
      } else {
        _notificationService.showMessage('Invalid youtube video url');
      }
    } else {
      _notificationService.showMessage(
        'Not Implemented. Currently only youtube videos are supported',
      );
    }

    return null;
  }

  Future createNewArticle(String content) async {
    print(content);
  }
}
