import 'package:flutter/foundation.dart';

class SignUpRequestDto {
  final String email;
  final String username;
  final String password;

  SignUpRequestDto({
    @required this.email,
    @required this.username,
    @required this.password,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['email'] = email;
    map['username'] = username;
    map['password'] = password;

    return map;
  }
}
