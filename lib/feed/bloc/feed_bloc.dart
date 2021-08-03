import 'feed_actions.dart';
import '../services/feed_service.dart';
import '../../general/bloc/bloc.dart';

class FeedBloc extends Bloc<FeedAction> {
  final FeedService _feedService;

  FeedBloc(this._feedService) {
    actionChannel.stream.listen(
      (action) {
        if (action is CreateNewArticle) {
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

  void _createNewArticle(CreateNewArticle action) async {
    await _feedService.createNewArticle(action.content);
  }
}
