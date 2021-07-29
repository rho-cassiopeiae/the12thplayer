import 'dart:async';

import 'video_reaction_actions.dart';
import 'video_reaction_states.dart';
import '../services/video_reaction_service.dart';
import '../../../../general/bloc/bloc.dart';

class VideoReactionBloc extends Bloc<VideoReactionAction> {
  final VideoReactionService _videoReactionService;

  StreamController<LoadVideoReactionsState> _videoReactionsStateChannel =
      StreamController<LoadVideoReactionsState>.broadcast();
  Stream<LoadVideoReactionsState> get videoReactionsState$ =>
      _videoReactionsStateChannel.stream;

  VideoReactionBloc(this._videoReactionService) {
    actionChannel.stream.listen((action) {
      if (action is LoadVideoReactions) {
        _loadVideoReactions(action);
      } else if (action is VoteForVideoReaction) {
        _voteForVideoReaction(action);
      } else if (action is PostVideoReaction) {
        _postVideoReaction(action);
      } else if (action is GetVideoQualityUrls) {
        _getVideoQualityUrls(action);
      }
    });
  }

  @override
  void dispose({cleanupAction}) {
    _videoReactionsStateChannel.close();
    _videoReactionsStateChannel = null;
    actionChannel.close();
    actionChannel = null;
  }

  void _loadVideoReactions(LoadVideoReactions action) async {
    var result = await _videoReactionService.loadVideoReactions(
      action.fixtureId,
      action.filter,
      action.start,
    );

    var state = result.fold(
      (error) => VideoReactionsError(message: error.toString()),
      (fixtureVideoReactions) => VideoReactionsReady(
        fixtureVideoReactions: fixtureVideoReactions,
      ),
    );

    _videoReactionsStateChannel?.add(state);
  }

  void _voteForVideoReaction(VoteForVideoReaction action) async {
    await for (var result in _videoReactionService.voteForVideoReaction(
      action.fixtureId,
      action.authorId,
      action.voteAction,
      action.fixtureVideoReactions,
    )) {
      var state = result.fold(
        (error) => VideoReactionsError(message: error.toString()),
        (fixtureVideoReactions) => VideoReactionsReady(
          fixtureVideoReactions: fixtureVideoReactions,
        ),
      );

      _videoReactionsStateChannel?.add(state);
    }
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
      (error) => VideoQualityUrlsError(message: error.toString()),
      (qualityToUrl) => VideoQualityUrlsReady(qualityToUrl: qualityToUrl),
    );

    action.complete(state);
  }
}
