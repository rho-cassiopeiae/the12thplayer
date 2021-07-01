class TeamDto {
  final int id;
  final String name;
  final String logoUrl;

  TeamDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        logoUrl = map['logoUrl'];
}
