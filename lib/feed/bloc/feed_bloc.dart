import 'feed_states.dart';
import 'feed_actions.dart';
import '../services/feed_service.dart';
import '../../general/bloc/bloc.dart';

class FeedBloc extends Bloc<FeedAction> {
  final FeedService _feedService;

  FeedBloc(this._feedService) {
    actionChannel.stream.listen(
      (action) {
        if (action is SubscribeToFeed) {
          _subscribeToFeed(action);
        } else if (action is ProcessVideoUrl) {
          _processVideoUrl(action);
        } else if (action is CreateNewArticle) {
          _createNewArticle(action);
        }
      },
    );
  }

  @override
  void dispose({FeedAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
  }

  void _subscribeToFeed(SubscribeToFeed action) async {}

  void _processVideoUrl(ProcessVideoUrl action) async {
    var videoData = await _feedService.processVideoUrl(action.url);
    if (videoData != null) {
      action.complete(ProcessVideoUrlReady(videoData: videoData));
    } else {
      action.complete(ProcessVideoUrlError());
    }
  }

  void _createNewArticle(CreateNewArticle action) async {
    await _feedService.createNewArticle(action.content);
  }
}
