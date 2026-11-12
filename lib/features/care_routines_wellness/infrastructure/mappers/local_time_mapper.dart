import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';

/// The platform sends times of day as "22:00" or "22:00:00".
abstract final class LocalTimeMapper {
  static LocalTime fromApi(String value) {
    final parts = value.split(':');
    return LocalTime(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
