class TeamMatchEventsDto {
  final int teamId;
  final Iterable<MatchEventDto> events;

  TeamMatchEventsDto.fromMap(Map<String, dynamic> map)
      : teamId = map['teamId'],
        events = map['events'] == null
            ? null
            : (map['events'] as List<dynamic>)
                .map((eventMap) => MatchEventDto.fromMap(eventMap));
}

class MatchEventDto {
  final int minute;
  final int addedTimeMinute;
  final String type;
  final int playerId;
  final int relatedPlayerId;

  MatchEventDto.fromMap(Map<String, dynamic> map)
      : minute = map['minute'],
        addedTimeMinute = map['addedTimeMinute'],
        type = map['type'],
        playerId = map['playerId'],
        relatedPlayerId = map['relatedPlayerId'];
}
