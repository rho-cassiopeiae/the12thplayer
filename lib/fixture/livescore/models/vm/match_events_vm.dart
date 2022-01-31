import 'package:flutter/foundation.dart';

import '../../../common/models/entities/fixture_entity.dart';
import '../../../common/models/entities/team_match_events_entity.dart';

class MatchEventsVm {
  List<MatchEventGroupVm> _groups;
  List<MatchEventGroupVm> get groups => _groups;

  MatchEventsVm.fromEntity(FixtureEntity fixture) {
    var teamEvents = fixture.events != null
        ? fixture.events
            .firstWhere((events) => events.teamId == fixture.teamId)
            .events
        : <MatchEventEntity>[];
    var opponentTeamEvents = fixture.events != null
        ? fixture.events
            .firstWhere((events) => events.teamId == fixture.opponentTeamId)
            .events
        : <MatchEventEntity>[];

    var homeTeamEvents = fixture.homeStatus ? teamEvents : opponentTeamEvents;
    var awayTeamEvents = fixture.homeStatus ? opponentTeamEvents : teamEvents;

    // @@TODO: Deal with penalty shootout events.
    var players = fixture.allPlayers;
    _groups = [];

    for (var event in homeTeamEvents) {
      var addedTimeMinute =
          event.addedTimeMinute != null ? '+${event.addedTimeMinute}' : '';
      var minute = '${event.minute}$addedTimeMinute';

      var group = _groups.firstWhere(
        (eventGroup) => eventGroup.minute == minute,
        orElse: () => null,
      );
      if (group == null) {
        group = MatchEventGroupVm(minute: minute);
        _groups.add(group);
      }

      if (event.playerId != null) {
        var player = players.firstWhere(
          (player) => player.id == event.playerId,
          orElse: () => null,
        );
        if (player != null) {
          var relatedPlayer = event.relatedPlayerId != null
              ? players.firstWhere(
                  (player) => player.id == event.relatedPlayerId,
                  orElse: () => null,
                )
              : null;

          group.homeTeamEvents.add(
            MatchEventVm.fromEntity(
              event,
              player.getDisplayName(),
              relatedPlayer?.getDisplayName(),
            ),
          );
        }
      }
    }

    for (var event in awayTeamEvents) {
      var addedTimeMinute =
          event.addedTimeMinute != null ? '+${event.addedTimeMinute}' : '';
      var minute = '${event.minute}$addedTimeMinute';

      var group = _groups.firstWhere(
        (eventGroup) => eventGroup.minute == minute,
        orElse: () => null,
      );
      if (group == null) {
        group = MatchEventGroupVm(minute: minute);
        _groups.add(group);
      }

      if (event.playerId != null) {
        var player = players.firstWhere(
          (player) => player.id == event.playerId,
          orElse: () => null,
        );
        if (player != null) {
          var relatedPlayer = event.relatedPlayerId != null
              ? players.firstWhere(
                  (player) => player.id == event.relatedPlayerId,
                  orElse: () => null,
                )
              : null;

          group.awayTeamEvents.add(
            MatchEventVm.fromEntity(
              event,
              player.getDisplayName(),
              relatedPlayer?.getDisplayName(),
            ),
          );
        }
      }
    }

    _groups.sort((g1, g2) {
      var minute1Split = g1.minute.split('+');
      var minute1 = minute1Split.length == 1
          ? double.parse(minute1Split[0])
          : double.parse(minute1Split[0]) +
              double.parse(minute1Split[1]) / 100.0;

      var minute2Split = g2.minute.split('+');
      var minute2 = minute2Split.length == 1
          ? double.parse(minute2Split[0])
          : double.parse(minute2Split[0]) +
              double.parse(minute2Split[1]) / 100.0;

      return minute2.compareTo(minute1);
    });
  }
}

class MatchEventGroupVm {
  final String minute;
  final List<MatchEventVm> homeTeamEvents = [];
  final List<MatchEventVm> awayTeamEvents = [];

  MatchEventGroupVm({@required this.minute});
}

class MatchEventVm {
  final String type;
  final String playerDisplayName;
  final String relatedPlayerDisplayName;

  bool get isSub => type == 'substitution';

  MatchEventVm.fromEntity(
    MatchEventEntity event,
    String playerDisplayName,
    String relatedPlayerDisplayName,
  )   : type = event.type,
        playerDisplayName = playerDisplayName,
        relatedPlayerDisplayName = relatedPlayerDisplayName;
}
