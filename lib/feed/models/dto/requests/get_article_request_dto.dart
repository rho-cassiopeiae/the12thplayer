import 'package:flutter/foundation.dart';

class GetArticleRequestDto {
  final int teamId;
  final DateTime postedAt;

  GetArticleRequestDto({
    @required this.teamId,
    @required this.postedAt,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['teamId'] = teamId;
    map['postedAt'] = postedAt.millisecondsSinceEpoch;

    return map;
  }
}
