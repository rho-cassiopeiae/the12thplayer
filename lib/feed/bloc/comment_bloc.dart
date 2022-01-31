import 'package:rxdart/rxdart.dart';

import '../services/feed_service.dart';
import 'comment_states.dart';
import '../../general/bloc/bloc.dart';
import 'comment_actions.dart';

class CommentBloc extends Bloc<CommentAction> {
  final FeedService _feedService;

  BehaviorSubject<VoteForComment> _voteActionChannel =
      BehaviorSubject<VoteForComment>();

  BehaviorSubject<LoadCommentsState> _articleCommentsStateChannel =
      BehaviorSubject<LoadCommentsState>();
  Stream<LoadCommentsState> get articleCommentsState$ =>
      _articleCommentsStateChannel.stream;

  CommentBloc(this._feedService) {
    actionChannel.stream.listen((action) {
      if (action is LoadComments) {
        _loadComments(action);
      } else if (action is VoteForComment) {
        _voteActionChannel.add(action);
      } else if (action is PostComment) {
        _postComment(action);
      }
    });

    _voteActionChannel
        .debounceTime(Duration(seconds: 1))
        .listen((action) => _voteForComment(action));
  }

  @override
  void dispose({CommentAction cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _voteActionChannel.close();
    _voteActionChannel = null;
    _articleCommentsStateChannel.close();
    _articleCommentsStateChannel = null;
  }

  void _loadComments(LoadComments action) async {
    var comments = await _feedService.loadComments(action.articleId);
    _articleCommentsStateChannel?.add(CommentsReady(comments: comments));
  }

  void _voteForComment(VoteForComment action) async {
    var comments = await _feedService.voteForComment(
      action.articleId,
      action.commentId,
      action.commentPath,
      action.userVote,
    );

    _articleCommentsStateChannel?.add(CommentsReady(comments: comments));
  }

  void _postComment(PostComment action) async {
    var result = await _feedService.postComment(
      action.articleId,
      action.commentPath,
      action.body,
    );

    var postedComment = result.item1;
    var state = postedComment != null
        ? CommentPostingSucceeded(comment: result.item1)
        : CommentPostingFailed();

    if (state is CommentPostingSucceeded) {
      _articleCommentsStateChannel?.add(CommentsReady(comments: result.item2));
    }

    action.complete(state);
  }
}
