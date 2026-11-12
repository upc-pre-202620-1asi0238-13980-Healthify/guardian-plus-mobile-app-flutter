import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/local_time_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/hydration_plan_dto.dart';

extension HydrationPlanDtoMapper on HydrationPlanDto {
  HydrationPlan toDomain() {
    return HydrationPlan(
      active: active,
      dailyGoalGlasses: dailyGoalGlasses,
      intervalHours: intervalHours,
      respectSleepWindow: respectSleepWindow,
      sleepWindowStart: sleepWindowStart != null ? LocalTimeMapper.fromApi(sleepWindowStart!) : null,
      sleepWindowEnd: sleepWindowEnd != null ? LocalTimeMapper.fromApi(sleepWindowEnd!) : null,
      glassesConsumedToday: glassesConsumedToday,
      remainingGlassesToday: remainingGlassesToday,
      nextReminderAt: nextReminderAt != null ? DateTime.parse(nextReminderAt!).toLocal() : null,
    );
  }
}
