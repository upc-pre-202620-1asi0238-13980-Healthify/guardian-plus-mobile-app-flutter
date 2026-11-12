import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_cycle_record.dart';

class SleepState {
  const new({
    this.isLoading = false,
    this.isLoaded = false,
    this.errorMessage,
    this.nights = const [],
    required this.now,
  });

  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;
  // Nights of the last week, most recent first
  final List<SleepCycleRecord> nights;
  final DateTime now;

  SleepCycleRecord? get lastNight => nights.firstOrNull;

  // Nullable fields take a function, so copyWith can also set them back to null
  SleepState copyWith({
    bool? isLoading,
    bool? isLoaded,
    ValueGetter<String?>? errorMessage,
    List<SleepCycleRecord>? nights,
    DateTime? now,
  }) {
    return SleepState(
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      nights: nights ?? this.nights,
      now: now ?? this.now,
    );
  }
}
