class ScoreDto {
  final int localTeam;
  final int visitorTeam;
  final String ht;
  final String ft;
  final String et;
  final String ps;

  ScoreDto.fromMap(Map<String, dynamic> map)
      : localTeam = map['localTeam'],
        visitorTeam = map['visitorTeam'],
        ht = map['ht'],
        ft = map['ft'],
        et = map['et'],
        ps = map['ps'];
}
