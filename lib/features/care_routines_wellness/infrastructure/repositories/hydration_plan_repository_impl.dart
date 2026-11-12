import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/hydration_plan_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/configure_hydration_plan_request_dto.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/hydration_plan_api.dart';

class HydrationPlanRepositoryImpl implements HydrationPlanRepository {
  final HydrationPlanApi api;

  const new({required this.api});

  // 404 is the platform's "no plan configured yet"
  @override
  Future<HydrationPlan?> getHydrationPlan(String personUnderCareId) async {
    try {
      final dto = await api.getHydrationPlan(personUnderCareId);
      return dto.toDomain();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<HydrationPlan> configureHydrationPlan({
    required String personUnderCareId,
    required bool active,
    required int dailyGoalGlasses,
    required int intervalHours,
    required bool respectSleepWindow,
  }) async {
    final dto = await api.configureHydrationPlan(
      personUnderCareId,
      ConfigureHydrationPlanRequestDto(
        active: active,
        dailyGoalGlasses: dailyGoalGlasses,
        intervalHours: intervalHours,
        respectSleepWindow: respectSleepWindow,
      ),
    );
    return dto.toDomain();
  }
}
