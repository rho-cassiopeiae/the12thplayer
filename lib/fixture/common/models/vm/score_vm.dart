import '../entities/score_entity.dart';

class ScoreVm {
  final int localTeam;
  final int visitorTeam;
  final String ht;
  final String ft;
  final String et;
  final String ps;

  ScoreVm.fromEntity(ScoreEntity score)
      : localTeam = score.localTeam,
        visitorTeam = score.visitorTeam,
        ht = score.ht,
        ft = score.ft,
        et = score.et,
        ps = score.ps;

  @override
  String toString() => '$localTeam:$visitorTeam';
}
