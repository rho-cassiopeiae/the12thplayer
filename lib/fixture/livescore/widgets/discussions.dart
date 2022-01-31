import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

import '../discussion/bloc/discussion_states.dart';
import '../discussion/bloc/discussion_actions.dart';
import '../discussion/bloc/discussion_bloc.dart';
import '../discussion/models/vm/discussion_vm.dart';
import '../discussion/pages/discussion_page.dart';

class Discussions {
  final int fixtureId;
  final ThemeData theme;
  final DiscussionBloc discussionBloc;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  Discussions({
    @required this.fixtureId,
    @required this.theme,
    @required this.discussionBloc,
  }) {
    _loadDiscussions();
  }

  void _loadDiscussions() {
    discussionBloc.dispatchAction(
      LoadDiscussions(fixtureId: fixtureId),
    );
  }

  List<Widget> build({@required BuildContext context}) {
    return [
      SliverToBoxAdapter(
        child: Container(
          height: 50.0,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
            boxShadow: [
              BoxShadow(
                color: _color,
                blurRadius: 0.0,
                spreadRadius: 0.0,
                offset: Offset(0.0, 2.0),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Spacer(),
              Text(
                'Discussion rooms',
                style: GoogleFonts.exo2(
                  textStyle: TextStyle(
                    color: theme.primaryColorDark,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.grey,
                    ),
                    onPressed: _loadDiscussions,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      StreamBuilder<LoadDiscussionsState>(
        initialData: DiscussionsLoading(),
        stream: discussionBloc.discussionsState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is DiscussionsLoading || state is DiscussionsError) {
            return SliverToBoxAdapter(child: SizedBox.shrink());
          }

          var discussions =
              (state as DiscussionsReady).fixtureDiscussions.discussions;

          return SliverFixedExtentList(
            itemExtent: 130.0,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var discussion = discussions[index];
                return Container(
                  decoration: BoxDecoration(
                    color: _color,
                    boxShadow: [
                      BoxShadow(
                        color: _color,
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                        offset: Offset(0.0, 2.0),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  child: _buildDiscussion(context, discussion, index),
                );
              },
              childCount: discussions.length,
            ),
          );
        },
      ),
      StreamBuilder<LoadDiscussionsState>(
        initialData: DiscussionsLoading(),
        stream: discussionBloc.discussionsState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is DiscussionsLoading) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                color: _color,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          }

          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: _color,
            ),
          );
        },
      ),
    ];
  }

  Widget _buildDiscussion(
    BuildContext context,
    DiscussionVm discussion,
    int index,
  ) {
    var widgets = [
      InkWell(
        onTap: () async {
          await Navigator.of(context).pushNamed(
            DiscussionPage.routeName,
            arguments: Tuple2(fixtureId, discussion.id),
          );

          _loadDiscussions();
        },
        child: Card(
          color: _getDiscussionColor(discussion),
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.grey[200],
              width: 4.0,
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Spacer(flex: 5),
                Text(
                  '${discussion.name[0].toUpperCase()}${discussion.name.substring(1)} discussion',
                  style: GoogleFonts.girassol(
                    fontSize: 22.0,
                    color: Colors.white,
                  ),
                ),
                Spacer(flex: 2),
                Text(
                  discussion.active ? 'active' : 'inactive',
                  style: GoogleFonts.courgette(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
                Spacer(flex: 5),
              ],
            ),
          ),
        ),
      ),
      Expanded(
        child: Center(
          child: Container(
            width: discussion.name == 'post-match' ? 50.0 : 60.0,
            height: discussion.name == 'post-match' ? 55.0 : 60.0,
            child: Image.asset(
              'assets/images/${discussion.name}.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ];

    return index % 2 == 0
        ? Row(children: widgets)
        : Row(children: widgets.reversed.toList());
  }

  Color _getDiscussionColor(DiscussionVm discussion) =>
      discussion.name == 'pre-match'
          ? const Color(0xff57cc99)
          : discussion.name == 'match'
              ? const Color(0xff7371fc)
              : const Color(0xffef6351);
}
