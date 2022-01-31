import 'package:flutter/foundation.dart';

class TeamDto {
  final int id;
  final String name;
  final String logoUrl;

  TeamDto({
    @required this.id,
    @required this.name,
    @required this.logoUrl,
  });

  TeamDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        logoUrl = map['logoUrl'];
}
