import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan.dart';

abstract class HydrationPlanRepository {
  /// Null while the family has not configured a plan yet.
  Future<HydrationPlan?> getHydrationPlan(String personUnderCareId);

  /// Creates or changes the plan; switching it or changing the interval replaces the pending reminders.
  Future<HydrationPlan> configureHydrationPlan({
    required String personUnderCareId,
    required bool active,
    required int dailyGoalGlasses,
    required int intervalHours,
    required bool respectSleepWindow,
  });
}
