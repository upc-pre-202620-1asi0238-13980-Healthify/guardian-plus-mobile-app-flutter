import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';

/// One past reading. Unlike LiveVitalSign it carries no classification: the history endpoint does not send it.
class VitalSignReading {
  final String id;
  final VitalSignType type;
  final double value;
  final DateTime measuredAt;

  const new({required this.id, required this.type, required this.value, required this.measuredAt});
}
