import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/players_view.dart';
import '../../general/widgets/app_drawer.dart';
import '../bloc/team_actions.dart';
import '../bloc/team_states.dart';
import '../models/vm/manager_vm.dart';
import '../models/vm/player_vm.dart';
import '../../general/extensions/kiwi_extension.dart';
import '../bloc/team_bloc.dart';

class TeamSquadPage extends StatelessWidgetWith<TeamBloc> {
  static const routeName = '/team/squad';

  @override
  Widget buildWith(BuildContext context, TeamBloc teamBloc) {
    teamBloc.dispatchAction(LoadTeamSquad());

    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff00406c),
      appBar: AppBar(
        backgroundColor: const Color(0xff002e4e),
        title: Text(
          'The 12th Player',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
            ),
          ),
        ),
        brightness: Brightness.dark,
        centerTitle: true,
        elevation: 5.0,
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<LoadTeamSquadState>(
        initialData: TeamSquadLoading(),
        stream: teamBloc.teamSquadState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is TeamSquadLoading) {
            return Center(child: CircularProgressIndicator());
          }

          var teamSquad = (state as TeamSquadReady).teamSquad;

          return CustomScrollView(
            slivers: [
              if (teamSquad.manager != null)
                _buildTeamMembers(
                  'Manager',
                  teamSquad.manager,
                  null,
                  width,
                ),
              _buildTeamMembers(
                'Goalkeepers',
                null,
                teamSquad.goalkeepers,
                width,
              ),
              _buildTeamMembers(
                'Defenders',
                null,
                teamSquad.defenders,
                width,
              ),
              _buildTeamMembers(
                'Midfielders',
                null,
                teamSquad.midfielders,
                width,
              ),
              _buildTeamMembers(
                'Attackers',
                null,
                teamSquad.attackers,
                width,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTeamMembers(
    String header,
    ManagerVm manager,
    List<PlayerVm> players,
    double width,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            RotatedBox(
              quarterTurns: 3,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  header,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Fifa',
                    fontSize: 30.0,
                  ),
                ),
              ),
            ),
            PlayersView(
              height: 400.0,
              viewFraction: min(
                (400.0 * 496.0 / 792.0 + 22.0) / width,
                1.0,
              ),
              manager: manager,
              players: players,
            ),
          ],
        ),
      ),
    );
  }
}
