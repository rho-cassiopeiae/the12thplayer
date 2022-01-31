import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class VideoPlayer extends StatefulWidget {
  final Map<String, String> qualityToUrl;

  const VideoPlayer({
    Key key,
    @required this.qualityToUrl,
  }) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  BetterPlayerController _controller; // @@NOTE: Controller is auto-disposed.

  @override
  void initState() {
    super.initState();

    var qualityEntries = widget.qualityToUrl.entries.toList();
    qualityEntries.sort(
      (e1, e2) => int.parse(e2.key).compareTo(int.parse(e1.key)),
    );

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16.0 / 9.0,
        autoPlay: true,
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        qualityEntries.first.value,
        resolutions: widget.qualityToUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: BetterPlayer(controller: _controller),
    );
  }
}
