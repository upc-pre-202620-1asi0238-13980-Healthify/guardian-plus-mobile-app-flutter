import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan_repository.dart';

class GetHydrationPlanUseCase {
  final HydrationPlanRepository repository;

  const new({required this.repository});

  Future<HydrationPlan?> execute(String personUnderCareId) {
    return repository.getHydrationPlan(personUnderCareId);
  }
}
