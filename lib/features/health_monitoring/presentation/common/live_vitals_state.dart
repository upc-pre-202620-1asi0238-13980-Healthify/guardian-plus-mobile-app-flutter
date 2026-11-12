import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_signs.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_reading.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';

enum VitalTrend { stable, rising, falling }

/// What "Inicio" and "Salud › Ahora" show: the latest readings and today's ones behind the sparkline.
class LiveVitalsState {
  const new({
    this.isLoading = false,
    this.errorMessage,
    this.careRecipientFirstName = '',
    this.vitals,
    this.hasWristband = false,
    required this.now,
    this.todayReadings = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final String careRecipientFirstName;
  final LiveVitalSigns? vitals;
  final bool hasWristband;
  // Time of the last refresh; "Hace 2 min" is measured against it
  final DateTime now;
  // Today's readings on the phone's calendar, oldest first: the history of the day plus every live refresh since
  final List<VitalSignReading> todayReadings;

  static const _trendWindow = 6;
  static const _trendTolerance = 0.1;

  bool get allWithinRange => vitals?.allWithinRange ?? false;

  bool get hasLiveSignal => vitals?.hasLiveSignal ?? false;

  // The backend stores systolic and diastolic as two readings; the screen shows them as one
  String? get bloodPressureText {
    final systolic = vitals?[VitalSignType.bpSys];
    final diastolic = vitals?[VitalSignType.bpDia];
    if (systolic == null || diastolic == null) return null;
    return '${systolic.value.round()}/${diastolic.value.round()}';
  }

  bool get bloodPressureOutOfRange =>
      vitals?[VitalSignType.bpSys]?.classification.isOutRange == true ||
      vitals?[VitalSignType.bpDia]?.classification.isOutRange == true;

  // Blood pressure is judged by both halves, the rest by their own reading
  bool isWithinRange(VitalSignType type) => type == VitalSignType.bpSys
      ? !bloodPressureOutOfRange
      : vitals?[type]?.classification.isOutRange != true;

  List<double> todayValues(VitalSignType type) =>
      todayReadings.where((reading) => reading.type == type).map((reading) => reading.value).toList();

  /// Latest reading against the few before it, measured in tenths of its normal range so every sign weighs alike.
  VitalTrend? trend(VitalSignType type) {
    final latest = vitals?[type];
    if (latest == null) return null;
    final earlier = todayReadings
        .where((reading) => reading.type == type && reading.measuredAt.isBefore(latest.measuredAt))
        .toList();
    if (earlier.isEmpty) return null;
    final window = earlier.sublist(earlier.length > _trendWindow ? earlier.length - _trendWindow : 0);
    final average = window.map((reading) => reading.value).reduce((a, b) => a + b) / window.length;
    final change = latest.value - average;
    final tolerance = (latest.normalMaximum - latest.normalMinimum) * _trendTolerance;
    if (change > tolerance) return VitalTrend.rising;
    if (change < -tolerance) return VitalTrend.falling;
    return VitalTrend.stable;
  }

  // A live reading may also come back in the history, so they are told apart by type and time, not by id
  LiveVitalsState withReadings(List<VitalSignReading> added) {
    final today = DateUtils.dateOnly(now.toLocal());
    final byKey = <(VitalSignType, DateTime), VitalSignReading>{};
    for (final reading in [...todayReadings, ...added]) {
      byKey.putIfAbsent((reading.type, reading.measuredAt), () => reading);
    }
    final readings = byKey.values
        .where((reading) => DateUtils.dateOnly(reading.measuredAt.toLocal()) == today)
        .toList()
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    return copyWith(todayReadings: readings);
  }

  // Nullable fields take a function, so copyWith can also set them back to null
  LiveVitalsState copyWith({
    bool? isLoading,
    ValueGetter<String?>? errorMessage,
    LiveVitalSigns? vitals,
    bool? hasWristband,
    DateTime? now,
    List<VitalSignReading>? todayReadings,
  }) {
    return LiveVitalsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      careRecipientFirstName: careRecipientFirstName,
      vitals: vitals ?? this.vitals,
      hasWristband: hasWristband ?? this.hasWristband,
      now: now ?? this.now,
      todayReadings: todayReadings ?? this.todayReadings,
    );
  }
}
