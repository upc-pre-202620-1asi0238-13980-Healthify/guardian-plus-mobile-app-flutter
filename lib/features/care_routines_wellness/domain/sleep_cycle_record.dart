import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_classification.dart';

/// A closed night of sleep measured by the wristband.
class SleepCycleRecord {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final int interruptionCount;
  // How continuous the night was, from 0 to 100
  final int continuityScore;
  final SleepClassification classification;

  const new({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.interruptionCount,
    required this.continuityScore,
    required this.classification,
  });
}