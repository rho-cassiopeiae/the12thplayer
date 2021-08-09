import 'package:flutter/foundation.dart';

import '../models/vm/article_vm.dart';
import '../models/video_data.dart';

abstract class FeedState {}

abstract class ProcessVideoUrlState extends FeedState {}

class ProcessVideoUrlReady extends ProcessVideoUrlState {
  final VideoData videoData;

  ProcessVideoUrlReady({@required this.videoData});
}

class ProcessVideoUrlError extends ProcessVideoUrlState {}

abstract class SaveArticlePreviewState extends FeedState {}

class SaveArticlePreviewReady extends SaveArticlePreviewState {}

class SaveArticlePreviewError extends SaveArticlePreviewState {}

class ArticleContentReady extends FeedState {
  final List<dynamic> content;

  ArticleContentReady({@required this.content});
}

class SaveArticleContentReady extends FeedState {}

abstract class PostArticleState extends FeedState {}

class PostArticleReady extends PostArticleState {}

class PostArticleError extends PostArticleState {}

abstract class ArticlesState extends FeedState {}

class ArticlesLoading extends ArticlesState {}

class ArticlesReady extends ArticlesState {
  final List<ArticleVm> articles;

  ArticlesReady({@required this.articles});
}

class ArticlesError extends ArticlesState {
  final String message;

  ArticlesError({@required this.message});
}

abstract class ArticleState extends FeedState {}

class ArticleReady extends ArticleState {
  final ArticleVm article;

  ArticleReady({@required this.article});
}

class ArticleError extends ArticleState {
  final String message;

  ArticleError({@required this.message});
}
