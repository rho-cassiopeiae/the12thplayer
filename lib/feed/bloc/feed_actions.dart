import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../enums/article_type.dart';
import 'feed_states.dart';

abstract class FeedAction {}

abstract class FeedActionFutureState<TState extends FeedState>
    extends FeedAction {
  final Completer<TState> _stateReady = Completer<TState>();
  Future<TState> get state => _stateReady.future;

  void complete(TState state) => _stateReady.complete(state);
}

class SubscribeToFeed extends FeedAction {}

class UnsubscribeFromFeed extends FeedAction {}

class LoadMoreArticles extends FeedActionFutureState<LoadMoreArticlesReady> {}

class LoadArticle extends FeedActionFutureState<ArticleState> {
  final DateTime postedAt;

  LoadArticle({@required this.postedAt});
}

class ProcessVideoUrl extends FeedActionFutureState<ProcessVideoUrlState> {
  final String url;

  ProcessVideoUrl({@required this.url});
}

class PostVideoArticle extends FeedActionFutureState<PostArticleState> {
  final ArticleType type;
  final String title;
  final Uint8List thumbnailBytes;
  final String videoUrl;
  final String summary;

  PostVideoArticle({
    @required this.type,
    @required this.title,
    @required this.thumbnailBytes,
    @required this.videoUrl,
    @required this.summary,
  });
}

class SaveArticlePreview
    extends FeedActionFutureState<SaveArticlePreviewState> {
  final String title;
  final String previewImageUrl;
  final String summary;

  SaveArticlePreview({
    @required this.title,
    @required this.previewImageUrl,
    @required this.summary,
  });
}

class LoadArticleContent extends FeedActionFutureState<ArticleContentReady> {}

class SaveArticleContent
    extends FeedActionFutureState<SaveArticleContentReady> {
  final List<dynamic> content;

  SaveArticleContent({@required this.content});
}

class PostArticle extends FeedActionFutureState<PostArticleState> {
  final ArticleType type;
  final List<dynamic> content;

  PostArticle({
    @required this.type,
    @required this.content,
  });
}
