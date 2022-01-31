import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'video_reaction_actions.dart';
import 'video_reaction_states.dart';
import '../services/video_reaction_service.dart';
import '../../../../general/bloc/bloc.dart';

class VideoReactionBloc extends Bloc<VideoReactionAction> {
  final VideoReactionService _videoReactionService;

  BehaviorSubject<VoteForVideoReaction> _voteActionChannel =
      BehaviorSubject<VoteForVideoReaction>();

  StreamController<LoadVideoReactionsState> _videoReactionsStateChannel =
      StreamController<LoadVideoReactionsState>.broadcast();
  Stream<LoadVideoReactionsState> get videoReactionsState$ =>
      _videoReactionsStateChannel.stream;

  VideoReactionBloc(this._videoReactionService) {
    actionChannel.stream.listen((action) {
      if (action is LoadVideoReactions) {
        _loadVideoReactions(action);
      } else if (action is VoteForVideoReaction) {
        _voteActionChannel.add(action);
      } else if (action is PostVideoReaction) {
        _postVideoReaction(action);
      } else if (action is GetVideoQualityUrls) {
        _getVideoQualityUrls(action);
      }
    });

    _voteActionChannel
        .debounceTime(Duration(seconds: 1))
        .listen((action) => _voteForVideoReaction(action));
  }

  @override
  void dispose({cleanupAction}) {
    actionChannel.close();
    actionChannel = null;
    _voteActionChannel.close();
    _voteActionChannel = null;
    _videoReactionsStateChannel.close();
    _videoReactionsStateChannel = null;
  }

  void _loadVideoReactions(LoadVideoReactions action) async {
    var fixtureVideoReactions = await _videoReactionService.loadVideoReactions(
      action.fixtureId,
      action.filter,
      action.page,
    );

    _videoReactionsStateChannel?.add(VideoReactionsReady(
      fixtureVideoReactions: fixtureVideoReactions,
    ));
  }

  void _voteForVideoReaction(VoteForVideoReaction action) async {
    var fixtureVideoReactions =
        await _videoReactionService.voteForVideoReaction(
      action.fixtureId,
      action.authorId,
      action.userVote,
    );

    _videoReactionsStateChannel?.add(VideoReactionsReady(
      fixtureVideoReactions: fixtureVideoReactions,
    ));
  }

  void _postVideoReaction(PostVideoReaction action) async {
    // @@TODO: Validation.

    _videoReactionService.postVideoReaction(
      action.fixtureId,
      action.title,
      action.videoBytes,
      action.fileName,
    );
  }

  void _getVideoQualityUrls(GetVideoQualityUrls action) async {
    var result = await _videoReactionService.getVideoQualityUrls(
      action.videoId,
    );

    var state = result.fold(
      (error) => VideoQualityUrlsError(),
      (qualityToUrl) => VideoQualityUrlsReady(qualityToUrl: qualityToUrl),
    );

    action.complete(state);
  }
}
