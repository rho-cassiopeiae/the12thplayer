import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../enums/subscription_state.dart';
import '../../icons/football.dart';
import '../bloc/live_commentary_feed_actions.dart';
import '../bloc/live_commentary_feed_bloc.dart';
import '../bloc/live_commentary_feed_states.dart';
import '../../../../general/extensions/kiwi_extension.dart';

class LiveCommentaryFeedPage extends StatefulWidget
    with DependencyResolver<LiveCommentaryFeedBloc> {
  static const routeName = '/fixture/livescore/live-commentary-feed';

  final int fixtureId;
  final int authorId;
  final String authorUsername;

  const LiveCommentaryFeedPage({
    Key key,
    @required this.fixtureId,
    @required this.authorId,
    @required this.authorUsername,
  }) : super(key: key);

  @override
  _LiveCommentaryFeedPageState createState() =>
      _LiveCommentaryFeedPageState(resolve());
}

class _LiveCommentaryFeedPageState extends State<LiveCommentaryFeedPage> {
  final LiveCommentaryFeedBloc _liveCommentaryFeedBloc;

  final Map<String, Icon> _eventToIcon = {
    'Goal': Icon(
      Football.football_ball_variant_1,
      color: Colors.purple[800],
    ),
    'Yellow card': Icon(
      Football.football_card_with_cross_mark,
      color: Colors.yellow[800],
    ),
    'Red card': Icon(
      Football.football_card_with_cross_mark,
      color: Colors.red[800],
    ),
    'Sub': Icon(
      Icons.swap_horizontal_circle_outlined,
      color: Colors.black,
    ),
  };

  SubscriptionState _subscriptionState = SubscriptionState.NotSubscribed;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  _LiveCommentaryFeedPageState(this._liveCommentaryFeedBloc);

  @override
  void initState() {
    super.initState();

    var action = LoadLiveCommentaryFeed(
      fixtureId: widget.fixtureId,
      authorId: widget.authorId,
    );
    _liveCommentaryFeedBloc.dispatchAction(action);

    action.state.then((state) {
      if (state is LiveCommentaryFeedReady &&
          _subscriptionState == SubscriptionState.NotSubscribed) {
        _subscriptionState = SubscriptionState.Subscribed;
        var entries = state.entries;
        _liveCommentaryFeedBloc.dispatchAction(
          SubscribeToLiveCommentaryFeed(
            fixtureId: widget.fixtureId,
            authorId: widget.authorId,
            lastReceivedEntryId: entries.isNotEmpty ? entries.first.id : null,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _liveCommentaryFeedBloc.dispose(
      cleanupAction: _subscriptionState == SubscriptionState.Subscribed
          ? UnsubscribeFromLiveCommentaryFeed(
              fixtureId: widget.fixtureId,
              authorId: widget.authorId,
            )
          : null,
    );
    _subscriptionState = SubscriptionState.Disposed;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _color,
      appBar: AppBar(
        backgroundColor: const Color(0xff023e8a),
        title: Text(
          'Live commentary by ${widget.authorUsername}',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
        brightness: Brightness.dark,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<LoadLiveCommentaryFeedState>(
        initialData: LiveCommentaryFeedLoading(),
        stream: _liveCommentaryFeedBloc.feedState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is LiveCommentaryFeedLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is LiveCommentaryFeedError) {
            return Center(child: Text(state.message));
          }

          var entries = (state as LiveCommentaryFeedReady).entries;
          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var entry = entries[index];
                    return Container(
                      margin: index == entries.length - 1
                          ? const EdgeInsets.only(bottom: 60)
                          : null,
                      child: Stack(
                        children: [
                          Card(
                            color: _color,
                            elevation: 8,
                            margin: const EdgeInsets.fromLTRB(53, 12, 12, 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Icon(
                                          entry.icon != null
                                              ? _eventToIcon[entry.icon].icon
                                              : Icons.ac_unit,
                                          size: 30,
                                          color: entry.icon != null
                                              ? _eventToIcon[entry.icon].color
                                              : _color,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          entry.title ?? '',
                                          style: GoogleFonts.exo2(
                                            textStyle: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                  if (entry.icon != null || entry.title != null)
                                    SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.body ?? '',
                                          style: GoogleFonts.exo2(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (entry.imageUrl != null)
                                        InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => Dialog(
                                                child: Container(
                                                  width: size.width * 0.7,
                                                  height: size.height * 0.7,
                                                  color: Colors.black87,
                                                  child: Image.network(
                                                    entry.imageUrl,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: size.width / 6,
                                            height: size.height / 6,
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Image.network(
                                              entry.imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 15,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: index == entries.length - 1
                                        ? BorderRadius.only(
                                            bottomLeft: Radius.circular(7.5),
                                            bottomRight: Radius.circular(7.5),
                                          )
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black87,
                                        blurRadius: 0.0,
                                        spreadRadius: 0.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                    color: Colors.black87,
                                  ),
                                ),
                                if (entry.time != null)
                                  CircleAvatar(
                                    backgroundColor: Colors.black87,
                                    radius: 22,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0,
                                      ),
                                      child: FittedBox(
                                        child: Text(
                                          entry.time,
                                          style: GoogleFonts.lexendMega(
                                            textStyle: TextStyle(
                                              color: _color,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: entries.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
