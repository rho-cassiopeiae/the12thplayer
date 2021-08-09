import 'dart:async';

import 'feed_states.dart';
import 'feed_actions.dart';
import '../services/feed_service.dart';
import '../../general/bloc/bloc.dart';

class FeedBloc extends Bloc<FeedAction> {
  final FeedService _feedService;

  StreamController<ArticlesState> _articlesStateChannel =
      StreamController<ArticlesState>.broadcast();
  Stream<ArticlesState> get articlesState$ => _articlesStateChannel.stream;

  FeedBloc(this._feedService) {
    actionChannel.stream.listen(
      (action) {
        if (action is SubscribeToFeed) {
          _subscribeToFeed(action);
        } else if (action is UnsubscribeFromFeed) {
          _unsubscribeFromFeed(action);
        } else if (action is LoadArticle) {
          _loadArticle(action);
        } else if (action is ProcessVideoUrl) {
          _processVideoUrl(action);
        } else if (action is PostVideoArticle) {
          _postVideoArticle(action);
        } else if (action is SaveArticlePreview) {
          _saveArticlePreview(action);
        } else if (action is LoadArticleContent) {
          _loadArticleContent(action);
        } else if (action is SaveArticleContent) {
          _saveArticleContent(action);
        } else if (action is PostArticle) {
          _postArticle(action);
        }
      },
    );
  }

  @override
  void dispose({FeedAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _articlesStateChannel.close();
    _articlesStateChannel = null;
  }

  void _subscribeToFeed(SubscribeToFeed action) async {
    await for (var update in _feedService.subscribeToFeed()) {
      var state = update.fold(
        (error) => ArticlesError(message: error.toString()),
        (articles) => ArticlesReady(articles: articles),
      );

      _articlesStateChannel?.add(state);
    }
  }

  void _unsubscribeFromFeed(UnsubscribeFromFeed action) {
    _feedService.unsubscribeFromFeed();
  }

  void _loadArticle(LoadArticle action) async {
    var result = await _feedService.loadArticle(action.postedAt);

    var state = result.fold(
      (error) => ArticleError(message: error.toString()),
      (article) => ArticleReady(article: article),
    );

    action.complete(state);
  }

  void _processVideoUrl(ProcessVideoUrl action) async {
    var videoData = await _feedService.processVideoUrl(action.url);
    if (videoData != null) {
      action.complete(ProcessVideoUrlReady(videoData: videoData));
    } else {
      action.complete(ProcessVideoUrlError());
    }
  }

  void _postVideoArticle(PostVideoArticle action) async {
    bool posted = await _feedService.postVideoArticle(
      action.type,
      action.title,
      action.thumbnailBytes,
      action.videoUrl,
      action.summary,
    );

    if (posted) {
      action.complete(PostArticleReady());
    } else {
      action.complete(PostArticleError());
    }
  }

  void _saveArticlePreview(SaveArticlePreview action) async {
    bool saved = await _feedService.saveArticlePreview(
      action.title,
      action.previewImageUrl,
      action.summary,
    );

    if (saved) {
      action.complete(SaveArticlePreviewReady());
    } else {
      action.complete(SaveArticlePreviewError());
    }
  }

  void _loadArticleContent(LoadArticleContent action) {
    List<dynamic> content = _feedService.loadArticleContent();
    action.complete(ArticleContentReady(content: content));
  }

  void _saveArticleContent(SaveArticleContent action) {
    _feedService.saveArticleContent(action.content);
    action.complete(SaveArticleContentReady());
  }

  void _postArticle(PostArticle action) async {
    bool posted = await _feedService.postArticle(
      action.type,
      action.content,
    );

    if (posted) {
      action.complete(PostArticleReady());
    } else {
      action.complete(PostArticleError());
    }
  }
}
