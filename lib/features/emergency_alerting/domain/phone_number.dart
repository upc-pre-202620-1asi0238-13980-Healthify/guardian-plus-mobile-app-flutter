/// Same rule as the platform's PhoneNumber value object: E.164, e.g. +51987654321.
abstract final class PhoneNumber {
  static final _e164 = RegExp(r'^\+[1-9]\d{7,14}$');

  static bool isValid(String value) => _e164.hasMatch(value);
}
