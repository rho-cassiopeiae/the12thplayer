import 'package:flutter/foundation.dart';

import '../models/vm/feed_articles_vm.dart';
import '../models/vm/article_vm.dart';
import '../models/vm/video_data_vm.dart';

abstract class FeedState {}

abstract class ProcessVideoUrlState extends FeedState {}

class VideoUrlProcessingSucceeded extends ProcessVideoUrlState {
  final VideoDataVm videoData;

  VideoUrlProcessingSucceeded({@required this.videoData});
}

class VideoUrlProcessingFailed extends ProcessVideoUrlState {}

abstract class SaveArticlePreviewState extends FeedState {}

class ArticlePreviewSavingSucceeded extends SaveArticlePreviewState {}

class ArticlePreviewSavingFailed extends SaveArticlePreviewState {}

abstract class LoadArticleContentState extends FeedState {}

class ArticleContentReady extends LoadArticleContentState {
  final List<dynamic> content;

  ArticleContentReady({@required this.content});
}

abstract class SaveArticleContentState extends FeedState {}

class ArticleContentSavingSucceeded extends SaveArticleContentState {}

abstract class PostArticleState extends FeedState {}

class ArticlePostingSucceeded extends PostArticleState {}

class ArticlePostingFailed extends PostArticleState {}

abstract class LoadArticlesState extends FeedState {}

class ArticlesLoading extends LoadArticlesState {}

class ArticlesReady extends LoadArticlesState {
  final FeedArticlesVm feedArticles;

  ArticlesReady({@required this.feedArticles});
}

abstract class LoadArticleState extends FeedState {}

class ArticleReady extends LoadArticleState {
  final ArticleVm article;

  ArticleReady({@required this.article});
}

class ArticleError extends LoadArticleState {}
