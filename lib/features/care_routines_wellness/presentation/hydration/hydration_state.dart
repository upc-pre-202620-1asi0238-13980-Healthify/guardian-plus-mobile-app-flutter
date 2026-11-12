import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan.dart';

/// What the settings show; before the first plan exists, the defaults the first change will create.
class HydrationSettings {
  final bool active;
  final int dailyGoalGlasses;
  final int intervalHours;
  final bool respectSleepWindow;

  const new({
    required this.active,
    required this.dailyGoalGlasses,
    required this.intervalHours,
    required this.respectSleepWindow,
  });

  static const defaults = HydrationSettings(
    active: false,
    dailyGoalGlasses: 6,
    intervalHours: 2,
    respectSleepWindow: true,
  );

  factory HydrationSettings.of(HydrationPlan plan) {
    return HydrationSettings(
      active: plan.active,
      dailyGoalGlasses: plan.dailyGoalGlasses,
      intervalHours: plan.intervalHours,
      respectSleepWindow: plan.respectSleepWindow,
    );
  }

  HydrationSettings copyWith({bool? active, int? dailyGoalGlasses, int? intervalHours, bool? respectSleepWindow}) {
    return HydrationSettings(
      active: active ?? this.active,
      dailyGoalGlasses: dailyGoalGlasses ?? this.dailyGoalGlasses,
      intervalHours: intervalHours ?? this.intervalHours,
      respectSleepWindow: respectSleepWindow ?? this.respectSleepWindow,
    );
  }
}

class HydrationState {
  const new({
    this.isLoading = false,
    this.isLoaded = false,
    this.errorMessage,
    this.plan,
    this.settings = HydrationSettings.defaults,
    this.isSaving = false,
    this.message,
  });

  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;
  // Null while the family has not configured a plan yet
  final HydrationPlan? plan;
  final HydrationSettings settings;
  final bool isSaving;
  final String? message;

  // Nullable fields take a function, so copyWith can also set them back to null
  HydrationState copyWith({
    bool? isLoading,
    bool? isLoaded,
    ValueGetter<String?>? errorMessage,
    ValueGetter<HydrationPlan?>? plan,
    HydrationSettings? settings,
    bool? isSaving,
    ValueGetter<String?>? message,
  }) {
    return HydrationState(
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      plan: plan != null ? plan() : this.plan,
      settings: settings ?? this.settings,
      isSaving: isSaving ?? this.isSaving,
      message: message != null ? message() : this.message,
    );
  }
}
