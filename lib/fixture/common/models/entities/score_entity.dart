import '../dto/score_dto.dart';

class ScoreEntity {
  final int localTeam;
  final int visitorTeam;
  final String ht;
  final String ft;
  final String et;
  final String ps;

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['localTeam'] = localTeam;
    map['visitorTeam'] = visitorTeam;
    map['ht'] = ht;
    map['ft'] = ft;
    map['et'] = et;
    map['ps'] = ps;

    return map;
  }

  ScoreEntity.fromMap(Map<String, dynamic> map)
      : localTeam = map['localTeam'],
        visitorTeam = map['visitorTeam'],
        ht = map['ht'],
        ft = map['ft'],
        et = map['et'],
        ps = map['ps'];

  ScoreEntity.fromDto(ScoreDto score)
      : localTeam = score.localTeam,
        visitorTeam = score.visitorTeam,
        ht = score.ht,
        ft = score.ft,
        et = score.et,
        ps = score.ps;
}
