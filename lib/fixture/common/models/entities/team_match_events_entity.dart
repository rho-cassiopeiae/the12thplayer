import '../dto/team_match_events_dto.dart';

class TeamMatchEventsEntity {
  final int teamId;
  final List<MatchEventEntity> events;

  TeamMatchEventsEntity.fromMap(Map<String, dynamic> map)
      : teamId = map['teamId'],
        events = map['events'] == null
            ? null
            : (map['events'] as List<dynamic>)
                .map((eventMap) => MatchEventEntity.fromMap(eventMap))
                .toList();

  TeamMatchEventsEntity.fromDto(TeamMatchEventsDto events)
      : teamId = events.teamId,
        events = events.events
            ?.map((event) => MatchEventEntity.fromDto(event))
            ?.toList();

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['teamId'] = teamId;
    map['events'] = events?.map((event) => event.toJson())?.toList();

    return map;
  }
}

class MatchEventEntity {
  final int minute;
  final int addedTimeMinute;
  final String type;
  final int playerId;
  final int relatedPlayerId;

  MatchEventEntity.fromMap(Map<String, dynamic> map)
      : minute = map['minute'],
        addedTimeMinute = map['addedTimeMinute'],
        type = map['type'],
        playerId = map['playerId'],
        relatedPlayerId = map['relatedPlayerId'];

  MatchEventEntity.fromDto(MatchEventDto event)
      : minute = event.minute,
        addedTimeMinute = event.addedTimeMinute,
        type = event.type,
        playerId = event.playerId,
        relatedPlayerId = event.relatedPlayerId;

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['minute'] = minute;
    map['addedTimeMinute'] = addedTimeMinute;
    map['type'] = type;
    map['playerId'] = playerId;
    map['relatedPlayerId'] = relatedPlayerId;

    return map;
  }
}
