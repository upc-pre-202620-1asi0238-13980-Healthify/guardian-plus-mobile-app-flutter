import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/configure_hydration_plan_request_dto.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/hydration_plan_dto.dart';

class HydrationPlanApi {
  final ApiClient client;

  const new({required this.client});

  Future<HydrationPlanDto> getHydrationPlan(String personUnderCareId) async {
    final json = await client.get('hydration-plans/citizen/$personUnderCareId');
    return HydrationPlanDto.fromJson(json);
  }

  Future<HydrationPlanDto> configureHydrationPlan(
    String personUnderCareId,
    ConfigureHydrationPlanRequestDto request,
  ) async {
    final json = await client.put('hydration-plans/citizen/$personUnderCareId', body: request.toJson());
    return HydrationPlanDto.fromJson(json);
  }
}
