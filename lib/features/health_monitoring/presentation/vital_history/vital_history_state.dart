import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_reading.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_filter.dart';

/// Normal range of a vital sign, both ends included.
typedef NormalRange = ({double min, double max});

class VitalHistoryState {
  const new({
    this.isLoading = false,
    this.errorMessage,
    this.readings = const [],
    this.ranges = const {},
    this.filter = const VitalFilter(),
    this.selectedType = VitalSignType.hr,
    this.period = HistoryPeriod.week,
    required this.today,
  });

  final bool isLoading;
  final String? errorMessage;
  // Oldest first, as the platform sends them; may include a few hours outside the period (see the view model)
  final List<VitalSignReading> readings;
  // History readings carry no range, so it is taken from the live endpoint
  final Map<VitalSignType, NormalRange> ranges;
  final VitalFilter filter;
  final VitalSignType selectedType;
  // The period the readings were loaded for, which trails the filter's while a new one loads
  final HistoryPeriod period;
  // Today on the phone's calendar, at midnight
  final DateTime today;

  static const _recentCount = 3;
  static const _hoursPerDay = 24;

  List<DateTime> get days => [
    for (var back = period.dayCount - 1; back >= 0; back--) DateTime(today.year, today.month, today.day - back),
  ];

  // Only what happened in the period on the phone's calendar
  List<VitalSignReading> get periodReadings {
    final firstDay = days.first;
    return readings.where((reading) {
      final day = _dayOf(reading);
      return !day.isBefore(firstDay) && !day.isAfter(today);
    }).toList();
  }

  // The chips only offer what the filter keeps, so a chip left out hands the chart to the first one kept
  VitalSignType get chartType => filter.types.contains(selectedType) ? selectedType : filter.types.first;

  List<VitalSignReading> readingsOf(VitalSignType type) =>
      periodReadings.where((reading) => reading.type == type).toList();

  // The average of nothing would print "NaN lpm"
  double? average(VitalSignType type) => _averageOf(readingsOf(type).map((reading) => reading.value));

  double? min(VitalSignType type) {
    final values = readingsOf(type).map((reading) => reading.value);
    return values.isEmpty ? null : values.reduce((a, b) => a < b ? a : b);
  }

  double? max(VitalSignType type) {
    final values = readingsOf(type).map((reading) => reading.value);
    return values.isEmpty ? null : values.reduce((a, b) => a > b ? a : b);
  }

  /// One point per hour for a day and per day otherwise; null where the wearable sent nothing.
  List<double?> chartValues(VitalSignType type) {
    final ofType = readingsOf(type);
    if (period == HistoryPeriod.day) {
      return [
        for (var hour = 0; hour < _hoursPerDay; hour++)
          _averageOf(ofType.where((reading) => reading.measuredAt.toLocal().hour == hour).map((r) => r.value)),
      ];
    }
    return [
      for (final day in days) _averageOf(ofType.where((reading) => _dayOf(reading) == day).map((r) => r.value)),
    ];
  }

  // Diastolic readings are shown inside their systolic row ("122/80"), never alone
  List<VitalSignReading> get recentReadings {
    final shown = periodReadings
        .where((reading) =>
            reading.type != VitalSignType.bpDia &&
            filter.includes(reading.type) &&
            filter.includesState(isWithinRange(reading)))
        .toList();
    return shown.sublist(shown.length > _recentCount ? shown.length - _recentCount : 0).reversed.toList();
  }

  VitalSignReading? diastolicFor(VitalSignReading systolic) => readings
      .where((reading) => reading.type == VitalSignType.bpDia && reading.measuredAt == systolic.measuredAt)
      .firstOrNull;

  // Without a known range there is nothing to warn about
  bool isWithinRange(VitalSignReading reading) {
    final range = ranges[reading.type];
    final withinOwnRange = range == null || (reading.value >= range.min && reading.value <= range.max);
    // A blood pressure row also covers its diastolic half
    final diastolic = reading.type == VitalSignType.bpSys ? diastolicFor(reading) : null;
    return withinOwnRange && (diastolic == null || isWithinRange(diastolic));
  }

  static DateTime _dayOf(VitalSignReading reading) => DateUtils.dateOnly(reading.measuredAt.toLocal());

  static double? _averageOf(Iterable<double> values) =>
      values.isEmpty ? null : values.reduce((a, b) => a + b) / values.length;

  // Nullable fields take a function, so copyWith can also set them back to null
  VitalHistoryState copyWith({
    bool? isLoading,
    ValueGetter<String?>? errorMessage,
    List<VitalSignReading>? readings,
    Map<VitalSignType, NormalRange>? ranges,
    VitalFilter? filter,
    VitalSignType? selectedType,
    HistoryPeriod? period,
    DateTime? today,
  }) {
    return VitalHistoryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      readings: readings ?? this.readings,
      ranges: ranges ?? this.ranges,
      filter: filter ?? this.filter,
      selectedType: selectedType ?? this.selectedType,
      period: period ?? this.period,
      today: today ?? this.today,
    );
  }
}
