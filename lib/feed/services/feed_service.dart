import 'dart:convert';
import 'dart:typed_data';

import 'package:either_option/either_option.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../enums/article_type.dart';
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

  String _title;
  String _previewImageUrl;
  String _summary;
  List<dynamic> _content;

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

  void unsubscribeFromFeed() async {
    var currentTeam = await _storage.loadCurrentTeam();
    _feedApiService.unsubscribeFromTeamFeed(currentTeam.id);
  }

  Future<Either<Error, ArticleVm>> loadArticle(DateTime postedAt) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var article = await _feedApiService.getArticle(currentTeam.id, postedAt);

      return Right(ArticleVm.fromDto(article));
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      return Left(Error(error.toString()));
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

  Future<bool> postVideoArticle(
    ArticleType type,
    String title,
    Uint8List thumbnailBytes,
    String videoUrl,
    String summary,
  ) async {
    // @@TODO: Validation.
    bool valid = true;
    if (!valid) {
      _notificationService.showMessage('Invalid input');
      return false;
    }

    try {
      var currentTeam = await _storage.loadCurrentTeam();

      _notificationService.showMessage(
        'The article has been submitted for review',
      );

      await _feedApiService.postVideoArticle(
        currentTeam.id,
        type,
        title,
        thumbnailBytes,
        summary,
        videoUrl,
      );

      return true;
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      _notificationService.showMessage(error.toString());

      return false;
    }
  }

  Future<bool> saveArticlePreview(
    String title,
    String previewImageUrl,
    String summary,
  ) async {
    // @@TODO: Validation.
    bool valid = true;
    if (valid) {
      _title = title;
      _previewImageUrl = previewImageUrl;
      _summary = summary;
    } else {
      _notificationService.showMessage('Invalid input');
    }

    return valid;
  }

  List<dynamic> loadArticleContent() => _content;

  void saveArticleContent(List<dynamic> content) {
    _content = content;
  }

  void _clearArticleData() {
    _title = null;
    _previewImageUrl = null;
    _summary = null;
    _content = null;
  }

  Future<bool> postArticle(ArticleType type, List<dynamic> content) async {
    // @@TODO: Validation.
    bool valid = true;
    if (!valid) {
      _notificationService.showMessage('Invalid input');
      return false;
    }

    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var contentString = jsonEncode(content);

      _notificationService.showMessage(
        'The article has been submitted for review',
      );

      await _feedApiService.postArticle(
        currentTeam.id,
        type,
        _title,
        _previewImageUrl,
        _summary,
        contentString,
      );

      _clearArticleData();

      return true;
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      _notificationService.showMessage(error.toString());

      return false;
    }
  }
}
