import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../enums/article_filter.dart';
import '../../general/bloc/mixins.dart';
import '../enums/article_type.dart';
import 'feed_states.dart';

abstract class FeedAction {}

abstract class FeedActionAwaitable<T extends FeedState> extends FeedAction
    with AwaitableState<T> {}

class LoadArticles extends FeedActionAwaitable<LoadArticlesState> {
  final ArticleFilter filter;
  final int page;

  LoadArticles({
    @required this.filter,
    @required this.page,
  });
}

class LoadArticle extends FeedActionAwaitable<LoadArticleState> {
  final int articleId;

  LoadArticle({@required this.articleId});
}

class ProcessVideoUrl extends FeedActionAwaitable<ProcessVideoUrlState> {
  final String url;

  ProcessVideoUrl({@required this.url});
}

class PostVideoArticle extends FeedActionAwaitable<PostArticleState> {
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

class SaveArticlePreview extends FeedActionAwaitable<SaveArticlePreviewState> {
  final String title;
  final String previewImageUrl;
  final String summary;

  SaveArticlePreview({
    @required this.title,
    @required this.previewImageUrl,
    @required this.summary,
  });
}

class LoadArticleContent extends FeedActionAwaitable<LoadArticleContentState> {}

class SaveArticleContent extends FeedActionAwaitable<SaveArticleContentState> {
  final List<dynamic> content;

  SaveArticleContent({@required this.content});
}

class PostArticle extends FeedActionAwaitable<PostArticleState> {
  final ArticleType type;
  final List<dynamic> content;

  PostArticle({
    @required this.type,
    @required this.content,
  });
}

class VoteForArticle extends FeedAction {
  final int articleId;
  final int userVote;

  VoteForArticle({
    @required this.articleId,
    @required this.userVote,
  });
}
