import '../dto/team_color_dto.dart';

class TeamColorEntity {
  final int teamId;
  final String color;

  TeamColorEntity.fromMap(Map<String, dynamic> map)
      : teamId = map['teamId'],
        color = map['color'];

  TeamColorEntity.fromDto(TeamColorDto color)
      : teamId = color.teamId,
        color = color.color;

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['teamId'] = teamId;
    map['color'] = color;

    return map;
  }
}
