import 'dart:math';

import 'package:flutter/material.dart';

import '../dto/discussion_entry_dto.dart';

class DiscussionEntryVm {
  static final List<Color> _colors = [
    const Color(0xff3b28cc),
    const Color(0xff2667ff),
    const Color(0xffef476f),
    const Color(0xff6411ad),
    const Color(0xff358f80),
    const Color(0xff773344),
    const Color(0xffef7b45),
  ];

  final String id;
  final int userId;
  final String username;
  final String body;
  Color _color;
  Color get color => _color;

  bool get isRootEntry => id == '0-1';

  DiscussionEntryVm.fromDto(
    DiscussionEntryDto entry,
    Map<int, Color> userIdToColor,
  )   : id = entry.id,
        userId = entry.userId,
        username = entry.username,
        body = entry.body {
    if (!userIdToColor.containsKey(userId)) {
      double sum = 0;
      var codeUnits = username.codeUnits;
      for (int i = 0; i < codeUnits.length; ++i) {
        sum += codeUnits[i] * sin(i + 1);
      }
      sum *= 10000;
      sum -= sum.floor();

      int index = (_colors.length * sum).floor();

      _color = _colors[index];
      userIdToColor[userId] = _color;
    } else {
      _color = userIdToColor[userId];
    }
  }
}
