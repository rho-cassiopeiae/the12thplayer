enum AuthPageMode {
  SignUp,
  SignIn,
  Confirm,
}

extension AuthPageModeExtension on AuthPageMode {
  String get name {
    switch (this) {
      case AuthPageMode.SignUp:
        return 'Sign-up';
      case AuthPageMode.SignIn:
        return 'Sign-in';
      case AuthPageMode.Confirm:
        return 'Confirm email';
    }

    return '';
  }
}
