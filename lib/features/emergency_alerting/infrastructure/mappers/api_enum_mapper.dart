/// The platform names enum values in upper snake case (FALL_DETECTED); Dart enums use lower camel case
/// (fallDetected). An unknown value is a contract mismatch, so it fails instead of picking a wrong one.
T enumFromApi<T extends Enum>(List<T> values, String value) {
  final name = value.toLowerCase().replaceAllMapped(RegExp(r'_([a-z0-9])'), (match) => match[1]!.toUpperCase());
  for (final candidate in values) {
    if (candidate.name == name) return candidate;
  }
  throw FormatException('Unknown value from the platform: $value');
}

/// fallDetected → FALL_DETECTED, the name the platform expects.
String enumToApi(Enum value) {
  return value.name.replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match[0]}').toUpperCase();
}
