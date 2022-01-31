import '../dto/score_dto.dart';

class ScoreVm {
  final int localTeam;
  final int visitorTeam;
  final String ht;
  final String ft;
  final String et;
  final String ps;

  ScoreVm.fromDto(ScoreDto score)
      : localTeam = score.localTeam,
        visitorTeam = score.visitorTeam,
        ht = score.ht,
        ft = score.ft,
        et = score.et,
        ps = score.ps;

  @override
  String toString() => '$localTeam:$visitorTeam';
}
