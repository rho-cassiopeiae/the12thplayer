import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../general/extensions/kiwi_extension.dart';
import '../bloc/match_predictions_actions.dart';
import '../bloc/match_predictions_bloc.dart';
import '../models/vm/fixture_vm.dart';

class PredictionField extends StatefulWidget
    with DependencyResolver<MatchPredictionsBloc> {
  final FixtureVm fixture;

  const PredictionField({
    Key key,
    @required this.fixture,
  }) : super(key: key);

  @override
  _PredictionFieldState createState() => _PredictionFieldState(resolve());
}

class _PredictionFieldState extends State<PredictionField> {
  final MatchPredictionsBloc _matchPredictionsBloc;

  TextEditingController _controller;
  FocusNode _focusNode;

  _PredictionFieldState(this._matchPredictionsBloc);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.fixture.predictedScore,
    );
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant PredictionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = widget.fixture.predictedScore;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      controller: _controller,
      focusNode: _focusNode,
      autoDisposeControllers: false,
      onTap: () => _controller.clear(),
      onChanged: (value) {},
      onCompleted: (value) => _matchPredictionsBloc.dispatchAction(
        AddDraftPrediction(
          fixtureId: widget.fixture.id,
          score: value,
        ),
      ),
      enabled: !widget.fixture.started,
      length: 2,
      textStyle: GoogleFonts.lexendMega(
        fontSize: 20.0,
      ),
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5.0),
        inactiveColor: Colors.black26,
        fieldHeight: 45.0,
        fieldWidth: 35.0,
      ),
      errorTextSpace: 0.0,
      keyboardType: TextInputType.number,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10.0,
          offset: const Offset(0.0, 1.0),
        ),
      ],
    );
  }
}
