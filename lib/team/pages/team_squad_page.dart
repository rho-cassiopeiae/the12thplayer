import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../general/widgets/app_drawer.dart';
import '../widgets/team_member_card.dart';
import '../models/vm/team_member_vm.dart';
import 'team_member_page.dart';
import '../bloc/team_actions.dart';
import '../bloc/team_states.dart';
import '../models/vm/manager_vm.dart';
import '../models/vm/player_vm.dart';
import '../../general/extensions/color_extension.dart';
import '../../general/extensions/kiwi_extension.dart';
import '../bloc/team_bloc.dart';

class TeamSquadPage extends StatelessWidgetInjected<TeamBloc> {
  static const routeName = '/team/squad';

  @override
  Widget buildInjected(BuildContext context, TeamBloc teamBloc) {
    teamBloc.dispatchAction(LoadTeamSquad());

    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 241, 246, 1.0),
      appBar: AppBar(
        backgroundColor: HexColor.fromHex('023e8a'),
        title: Text(
          'The 12th Player',
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
      drawer: AppDrawer(),
      body: StreamBuilder<TeamSquadState>(
        initialData: TeamSquadLoading(),
        stream: teamBloc.squadState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is TeamSquadLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TeamSquadError) {
            return Center(child: Text(state.message));
          }

          var teamSquad = (state as TeamSquadReady).teamSquad;

          return CustomScrollView(
            slivers: [
              ..._buildManager(context, theme, teamSquad.manager),
              ..._buildPlayers(
                context,
                theme,
                'Goalkeepers',
                teamSquad.goalkeepers,
              ),
              ..._buildPlayers(
                context,
                theme,
                'Defenders',
                teamSquad.defenders,
              ),
              ..._buildPlayers(
                context,
                theme,
                'Midfielders',
                teamSquad.midfielders,
              ),
              ..._buildPlayers(
                context,
                theme,
                'Attackers',
                teamSquad.attackers,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPositionHeader(String position, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        alignment: Alignment.center,
        child: Container(
          decoration: ShapeDecoration(
            color: theme.primaryColor,
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 5),
          child: Text(
            position,
            style: GoogleFonts.squadaOne(
              textStyle: TextStyle(
                fontSize: 29,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildManager(
    BuildContext context,
    ThemeData theme,
    ManagerVm manager,
  ) {
    return manager == null
        ? []
        : [
            SliverPadding(
              padding: const EdgeInsets.only(top: 8),
              sliver: _buildPositionHeader('Manager', theme),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 178,
                child: _buildMemberCard(context, manager),
              ),
            ),
          ];
  }

  List<Widget> _buildPlayers(
    BuildContext context,
    ThemeData theme,
    String header,
    List<PlayerVm> players,
  ) {
    return players.isEmpty
        ? []
        : [
            _buildPositionHeader(header, theme),
            SliverFixedExtentList(
              itemExtent: 178,
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildMemberCard(context, players[index]),
                childCount: players.length,
              ),
            ),
          ];
  }

  Widget _buildMemberCard(BuildContext context, TeamMemberVm teamMember) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          TeamMemberPage.routeName,
          arguments: teamMember,
        );
      },
      child: TeamMemberCard(
        teamMember: teamMember,
        borderColor: Colors.black54,
      ),
    );
  }
}
