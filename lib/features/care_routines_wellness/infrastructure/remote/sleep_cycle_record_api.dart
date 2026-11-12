import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/sleep_cycle_record_dto.dart';

class SleepCycleRecordApi {
  final ApiClient client;

  const new({required this.client});

  Future<List<SleepCycleRecordDto>> getSleepCycleRecords(String personUnderCareId, {String? from}) async {
    final query = Uri(queryParameters: {'from': ?from}).query;
    final path = 'sleep-cycle-records/citizen/$personUnderCareId';
    final List jsons = await client.get(query.isEmpty ? path : '$path?$query');
    return jsons.map((json) => SleepCycleRecordDto.fromJson(json)).toList();
  }
}
