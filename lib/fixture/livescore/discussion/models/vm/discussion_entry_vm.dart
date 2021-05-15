import 'dart:math';

import 'package:flutter/material.dart';

import '../dto/discussion_entry_dto.dart';
import '../../../../../general/extensions/color_extension.dart';

class DiscussionEntryVm {
  static final List<String> _colors = [
    'D9ED92',
    'B5E48C',
    '99D98C',
    '76C893',
    '52B69A',
    '34A0A4',
    '168AAD',
    '1A759F',
    '1E6091',
    '184E77',
  ];

  final String id;
  final String username;
  final String body;
  Color _color;
  Color get color => _color;

  bool get isRootEntry => id == '0-1';

  DiscussionEntryVm.fromDto(
    DiscussionEntryDto entry,
    Map<String, Color> usernameToColor,
  )   : id = entry.id,
        username = entry.username,
        body = entry.body {
    if (!usernameToColor.containsKey(username)) {
      double sum = 0;
      var codeUnits = username.codeUnits;
      for (int i = 0; i < codeUnits.length; ++i) {
        sum += codeUnits[i] * sin(i + 1);
      }
      sum *= 10000;
      sum -= sum.floor();

      int index = (_colors.length * sum).floor();

      _color = HexColor.fromHex(_colors[index]);
      usernameToColor[username] = _color;
    } else {
      _color = usernameToColor[username];
    }
  }
}
