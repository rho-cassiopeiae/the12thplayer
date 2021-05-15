import 'package:flutter/foundation.dart';

class SignInRequestDto {
  final String email;
  final String password;

  SignInRequestDto({
    @required this.email,
    @required this.password,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['email'] = email;
    map['password'] = password;

    return map;
  }
}
