import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_log_entry.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor.dart';

class InactivityState {
  const new({
    this.isLoading = false,
    this.isLoaded = false,
    this.errorMessage,
    this.monitor,
    this.detectionEnabled = false,
    this.thresholdMinutes = defaultThresholdMinutes,
    this.recentActivity = const [],
    required this.now,
    this.isSaving = false,
    this.message,
  });

  static const defaultThresholdMinutes = 60;

  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;
  // Null until the wristband reports activity or detection is configured
  final ActivityMonitor? monitor;
  final bool detectionEnabled;
  final int thresholdMinutes;
  final List<ActivityLogEntry> recentActivity;
  final DateTime now;
  final bool isSaving;
  final String? message;

  InactivityState withMonitor(ActivityMonitor monitor) {
    return copyWith(
      monitor: () => monitor,
      detectionEnabled: monitor.detectionEnabled,
      thresholdMinutes: monitor.thresholdMinutes,
    );
  }

  // Nullable fields take a function, so copyWith can also set them back to null
  InactivityState copyWith({
    bool? isLoading,
    bool? isLoaded,
    ValueGetter<String?>? errorMessage,
    ValueGetter<ActivityMonitor?>? monitor,
    bool? detectionEnabled,
    int? thresholdMinutes,
    List<ActivityLogEntry>? recentActivity,
    DateTime? now,
    bool? isSaving,
    ValueGetter<String?>? message,
  }) {
    return InactivityState(
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      monitor: monitor != null ? monitor() : this.monitor,
      detectionEnabled: detectionEnabled ?? this.detectionEnabled,
      thresholdMinutes: thresholdMinutes ?? this.thresholdMinutes,
      recentActivity: recentActivity ?? this.recentActivity,
      now: now ?? this.now,
      isSaving: isSaving ?? this.isSaving,
      message: message != null ? message() : this.message,
    );
  }
}
