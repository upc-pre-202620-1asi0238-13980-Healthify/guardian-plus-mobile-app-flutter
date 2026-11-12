import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_sign.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';

/// The latest reading of every vital sign of a care recipient.
class LiveVitalSigns {
  final String careRecipientProfileId;
  final DateTime retrievedAt;
  final List<LiveVitalSign> vitalSigns;

  const new({required this.careRecipientProfileId, required this.retrievedAt, required this.vitalSigns});

  /// Latest reading of a type, null if the wearable never sent one.
  LiveVitalSign? operator [](VitalSignType type) => vitalSigns.where((sign) => sign.type == type).firstOrNull;

  bool get allWithinRange => !vitalSigns.any((sign) => sign.classification.isOutRange);

  bool get hasLiveSignal => vitalSigns.any((sign) => sign.liveSignal);
}
