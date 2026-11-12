import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan_repository.dart';

/// Creates or changes the plan; switching it or changing the interval replaces the pending reminders.
class ConfigureHydrationPlanUseCase {
  final HydrationPlanRepository repository;

  const new({required this.repository});

  Future<HydrationPlan> execute({
    required String personUnderCareId,
    required bool active,
    required int dailyGoalGlasses,
    required int intervalHours,
    required bool respectSleepWindow,
  }) {
    return repository.configureHydrationPlan(
      personUnderCareId: personUnderCareId,
      active: active,
      dailyGoalGlasses: dailyGoalGlasses,
      intervalHours: intervalHours,
      respectSleepWindow: respectSleepWindow,
    );
  }
}