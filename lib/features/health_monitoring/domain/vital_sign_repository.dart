import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_signs.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_reading.dart';

abstract class VitalSignRepository {
  Future<LiveVitalSigns> getLiveVitalSigns(String careRecipientProfileId);

  /// Readings between two dates (UTC calendar of the platform, both included), oldest first.
  Future<List<VitalSignReading>> getVitalSignHistory(
    String careRecipientProfileId, {
    required DateTime from,
    required DateTime to,
  });
}
