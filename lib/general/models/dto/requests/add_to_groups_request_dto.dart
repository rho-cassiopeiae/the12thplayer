import 'package:flutter/foundation.dart';

class AddToGroupsRequestDto {
  final Iterable<String> groups;

  AddToGroupsRequestDto({@required this.groups});

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['groups'] = groups;

    return map;
  }
}
