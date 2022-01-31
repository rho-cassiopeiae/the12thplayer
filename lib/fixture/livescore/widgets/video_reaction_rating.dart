import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../video_reaction/bloc/video_reaction_actions.dart';
import '../video_reaction/bloc/video_reaction_bloc.dart';
import '../video_reaction/models/vm/video_reaction_vm.dart';
import '../../../general/extensions/kiwi_extension.dart';

class VideoReactionRating extends StatefulWidget
    with DependencyResolver<VideoReactionBloc> {
  final int fixtureId;
  final VideoReactionVm videoReaction;
  final Future<bool> Function() onProtectedActionInvoked;

  const VideoReactionRating({
    Key key,
    @required this.fixtureId,
    @required this.videoReaction,
    @required this.onProtectedActionInvoked,
  }) : super(key: key);

  @override
  _VideoReactionRatingState createState() =>
      _VideoReactionRatingState(resolve());
}

class _VideoReactionRatingState extends State<VideoReactionRating> {
  final VideoReactionBloc _videoReactionBloc;

  int _rating;
  int _userVote;

  _VideoReactionRatingState(this._videoReactionBloc);

  @override
  void initState() {
    super.initState();
    _rating = widget.videoReaction.rating;
    _userVote = widget.videoReaction.userVote;
  }

  @override
  void didUpdateWidget(covariant VideoReactionRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rating = widget.videoReaction.rating;
    _userVote = widget.videoReaction.userVote;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          child: Icon(
            Icons.thumb_down,
            color: _userVote == -1 ? Colors.orange : null,
          ),
          onTap: () async {
            bool canProceed = await widget.onProtectedActionInvoked();
            if (canProceed) {
              setState(() {
                int incrRatingBy;
                if (_userVote == null) {
                  _userVote = -1;
                  incrRatingBy = -1;
                } else if (_userVote == -1) {
                  _userVote = null;
                  incrRatingBy = 1;
                } else {
                  _userVote = -1;
                  incrRatingBy = -2;
                }

                _rating += incrRatingBy;
              });

              _videoReactionBloc.dispatchAction(
                VoteForVideoReaction(
                  fixtureId: widget.fixtureId,
                  authorId: widget.videoReaction.authorId,
                  userVote: _userVote,
                ),
              );
            }
          },
        ),
        Text(
          _rating.toString(),
          style: GoogleFonts.lexendMega(
            fontSize: 18.0,
          ),
        ),
        GestureDetector(
          child: Icon(
            Icons.thumb_up,
            color: _userVote == 1 ? Colors.orange : null,
          ),
          onTap: () async {
            bool canProceed = await widget.onProtectedActionInvoked();
            if (canProceed) {
              setState(() {
                int incrRatingBy;
                if (_userVote == null) {
                  _userVote = 1;
                  incrRatingBy = 1;
                } else if (_userVote == 1) {
                  _userVote = null;
                  incrRatingBy = -1;
                } else {
                  _userVote = 1;
                  incrRatingBy = 2;
                }

                _rating += incrRatingBy;
              });

              _videoReactionBloc.dispatchAction(
                VoteForVideoReaction(
                  fixtureId: widget.fixtureId,
                  authorId: widget.videoReaction.authorId,
                  userVote: _userVote,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
