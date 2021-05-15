import 'package:flutter/foundation.dart';

class ConfirmEmailRequestDto {
  final String email;
  final String confirmationCode;

  ConfirmEmailRequestDto({
    @required this.email,
    @required this.confirmationCode,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['email'] = email;
    map['confirmationCode'] = confirmationCode;

    return map;
  }
}
