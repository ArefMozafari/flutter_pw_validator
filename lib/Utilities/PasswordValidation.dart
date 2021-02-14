class PasswordValidation {
  PasswordValidation._();

  static bool hasMinLength(String password, int minLength) {
    return password.length >= minLength ? true : false;
  }

  static bool hasMinUppercase(String password, int uppercaseCount) {
    String pattern = '^(.*?[A-Z]){' + uppercaseCount.toString() + ',}';
    return password.contains(new RegExp(pattern));
  }

  static bool hasMinNumericChar(String password, int numericCount) {
    String pattern = '^(.*?[0-9]){' + numericCount.toString() + ',}';
    return password.contains(new RegExp(pattern));
  }

  static bool hasMinSpecialChar(String password, int specialCount) {
    String pattern =
        r"^(.*?[$&+,\:;/=?@#|'<>.^*()%!-]){" + specialCount.toString() + ",}";
    return password.contains(new RegExp(pattern));
  }
}
