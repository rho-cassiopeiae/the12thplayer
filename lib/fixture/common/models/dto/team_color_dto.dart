class TeamColorDto {
  final int teamId;
  final String color;

  TeamColorDto.fromMap(Map<String, dynamic> map)
      : teamId = map['teamId'],
        color = map['color'];
}
