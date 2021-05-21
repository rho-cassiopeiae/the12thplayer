import 'package:flutter/material.dart';

import '../video_reaction/bloc/video_reaction_actions.dart';
import '../video_reaction/bloc/video_reaction_bloc.dart';
import '../video_reaction/bloc/video_reaction_states.dart';
import '../widgets/video_player.dart';
import '../../../general/extensions/kiwi_extension.dart';

class VideoPage extends StatelessWidgetInjected<VideoReactionBloc> {
  static const routeName = '/fixture/livescore/video';

  final String videoId;

  VideoPage({@required this.videoId});

  @override
  Widget buildInjected(
    BuildContext context,
    VideoReactionBloc videoReactionBloc,
  ) {
    var action = GetVideoQualityUrls(videoId: videoId);
    videoReactionBloc.dispatchAction(action);

    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      child: FutureBuilder<GetVideoQualityUrlsState>(
        initialData: VideoQualityUrlsLoading(),
        future: action.state,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is VideoQualityUrlsLoading ||
              state is VideoQualityUrlsError) {
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          }

          var qualityToUrl = (state as VideoQualityUrlsReady).qualityToUrl;

          return VideoPlayer(qualityToUrl: qualityToUrl);
        },
      ),
    );
  }
}
