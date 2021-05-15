import 'package:flutter/foundation.dart';

class CreateLiveCommentaryRecordingRequestDto {
  final int fixtureId;
  final int teamId;
  final String name;

  CreateLiveCommentaryRecordingRequestDto({
    @required this.fixtureId,
    @required this.teamId,
    @required this.name,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['fixtureId'] = fixtureId;
    map['teamId'] = teamId;
    map['name'] = name;

    return map;
  }
}
