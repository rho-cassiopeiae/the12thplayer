import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../widgets/prediction_field.dart';
import '../bloc/match_predictions_actions.dart';
import '../bloc/match_predictions_states.dart';
import '../models/vm/fixture_vm.dart';
import '../../account/bloc/account_actions.dart';
import '../../account/bloc/account_bloc.dart';
import '../../account/bloc/account_states.dart';
import '../../account/enums/account_type.dart';
import '../../account/pages/auth_page.dart';
import '../../general/extensions/kiwi_extension.dart';
import '../../general/widgets/app_drawer.dart';
import '../../general/widgets/sweet_sheet.dart';
import '../bloc/match_predictions_bloc.dart';

class MatchPredictionsPage extends StatefulWidget
    with DependencyResolver2<MatchPredictionsBloc, AccountBloc> {
  static const routeName = '/match-predictions';

  const MatchPredictionsPage({Key key}) : super(key: key);

  @override
  _MatchPredictionsPageState createState() =>
      _MatchPredictionsPageState(resolve1(), resolve2());
}

class _MatchPredictionsPageState extends State<MatchPredictionsPage> {
  final MatchPredictionsBloc _matchPredictionsBloc;
  final AccountBloc _accountBloc;

  final SweetSheet _sweetSheet = SweetSheet();

  _MatchPredictionsPageState(
    this._matchPredictionsBloc,
    this._accountBloc,
  );

  @override
  void initState() {
    super.initState();
    _matchPredictionsBloc.dispatchAction(
      LoadActiveFixtures(clearDraftPredictions: true),
    );
  }

  @override
  void didUpdateWidget(covariant MatchPredictionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _matchPredictionsBloc.dispatchAction(
      LoadActiveFixtures(clearDraftPredictions: true),
    );
  }

  Future<bool> _showAuthDialogIfNecessary() async {
    var action = LoadAccount();
    _accountBloc.dispatchAction(action);

    var state = await action.state;
    if (state is AccountError) {
      return false;
    }

    var account = (state as AccountReady).account;
    if (account.type == AccountType.Guest) {
      bool goToAuthPage = await _sweetSheet.show<bool>(
        context: context,
        title: Text('Not authenticated'),
        description: Text('Authenticate to continue'),
        color: SweetSheetColor.WARNING,
        positive: SweetSheetAction(
          onPressed: () => Navigator.of(context).pop(true),
          title: 'SIGN-UP/IN/CONFIRM',
          icon: Icons.login,
        ),
        negative: SweetSheetAction(
          onPressed: () => Navigator.of(context).pop(false),
          title: 'CANCEL',
        ),
      );

      if (goToAuthPage ?? false) {
        Navigator.of(context).pushNamed(
          AuthPage.routeName,
          arguments: true,
        );
      }

      return false;
    }

    return true;
  }

  Widget _buildTeamLogoAndName(
    String teamName,
    String teamLogoUrl,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24.0,
        ),
        child: Column(
          children: [
            Container(
              width: 60.0,
              height: 60.0,
              child: Image.network(
                teamLogoUrl,
                fit: BoxFit.scaleDown,
              ),
            ),
            SizedBox(height: 12.0),
            AutoSizeText(
              teamName,
              style: GoogleFonts.exo2(
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
              maxLines: teamName.split(' ').length == 1 ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchStatus(FixtureVm fixture) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        fixture.isCompleted || fixture.isPostponed || fixture.isPaused
            ? fixture.status
            : fixture.isLive
                ? 'LIVE'
                : '',
        style: GoogleFonts.lexendMega(
          fontSize: 16.0,
          color: fixture.isLive
              ? Colors.red[400]
              : fixture.isPostponed
                  ? Colors.deepPurple[400]
                  : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1572A1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1572A1),
        title: Text(
          'The 12th Player',
          style: GoogleFonts.teko(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              bool canProceed = await _showAuthDialogIfNecessary();
              if (canProceed) {
                _matchPredictionsBloc.dispatchAction(SubmitMatchPredictions());
              }
            },
          ),
          IconButton(
            onPressed: () => _matchPredictionsBloc.dispatchAction(
              LoadActiveFixtures(clearDraftPredictions: false),
            ),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<LoadActiveFixturesState>(
        initialData: ActiveFixturesLoading(),
        stream: _matchPredictionsBloc.activeFixturesState$,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is ActiveFixturesLoading) {
            return Center(child: CircularProgressIndicator());
          }

          var seasonRound = (state as ActiveFixturesReady).seasonRound;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 4.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        seasonRound.leagueName,
                        style: GoogleFonts.permanentMarker(
                          fontSize: 16.0,
                          color: const Color(0xFF9AD0EC),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white, width: 2.0),
                          ),
                        ),
                        child: Text(
                          seasonRound.roundName,
                          style: GoogleFonts.permanentMarker(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverFixedExtentList(
                itemExtent: 246.0,
                delegate: SliverChildListDelegate(
                  seasonRound.fixtures.map((fixture) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 14.0,
                      ),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                      elevation: 5.0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTeamLogoAndName(
                                  fixture.homeTeamName,
                                  fixture.homeTeamLogoUrl,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat(
                                          'EEE, d MMM h:mm a',
                                        ).format(fixture.startTime),
                                        style: GoogleFonts.teko(
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      SizedBox(height: 6.0),
                                      Text(
                                        fixture.scoreString,
                                        style: GoogleFonts.lexendMega(
                                          fontSize: 26.0,
                                        ),
                                      ),
                                      if (!fixture.isUpcoming ||
                                          fixture.isPostponed)
                                        _buildMatchStatus(fixture),
                                    ],
                                  ),
                                ),
                                _buildTeamLogoAndName(
                                  fixture.guestTeamName,
                                  fixture.guestTeamLogoUrl,
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 1.0,
                                color: Colors.black12,
                              ),
                              Container(
                                width: 110.0,
                                height: 28.0,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurpleAccent,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4.0),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Prediction',
                                  style: GoogleFonts.permanentMarker(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 90.0,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PredictionField(fixture: fixture),
                                    Text(
                                      ':',
                                      style: GoogleFonts.lexendMega(
                                        fontSize: 24.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
