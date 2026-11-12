import 'package:guardian_plus_app/features/health_monitoring/domain/reading_classification.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';

/// Latest reading of one vital sign, judged against the normal range of its type.
class LiveVitalSign {
  final String id;
  final VitalSignType type;
  final String typeName;
  final String unit;
  final double value;
  final DateTime measuredAt;
  final double normalMinimum;
  final double normalMaximum;
  final ReadingClassification classification;
  // False when the reading is older than the live window (60 s): it is the last known value, not a live one
  final bool liveSignal;

  const new({
    required this.id,
    required this.type,
    required this.typeName,
    required this.unit,
    required this.value,
    required this.measuredAt,
    required this.normalMinimum,
    required this.normalMaximum,
    required this.classification,
    required this.liveSignal,
  });
}
