import 'dart:math';

import 'package:flutter/material.dart';

extension ColorExtension on Color {
  /// String is in the format 'aabbcc' or 'ffaabbcc' with an optional leading '#'.
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));

    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: _tintColor(color, 0.5),
    100: _tintColor(color, 0.4),
    200: _tintColor(color, 0.3),
    300: _tintColor(color, 0.2),
    400: _tintColor(color, 0.1),
    500: _tintColor(color, 0),
    600: _tintColor(color, -0.1),
    700: _tintColor(color, -0.2),
    800: _tintColor(color, -0.3),
    900: _tintColor(color, -0.4),
  });
}

int _tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color _tintColor(Color color, double factor) => Color.fromRGBO(
      _tintValue(color.red, factor),
      _tintValue(color.green, factor),
      _tintValue(color.blue, factor),
      1,
    );
