import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/reminder_dto.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/schedule_reminder_request_dto.dart';

class ReminderApi {
  final ApiClient client;

  const new({required this.client});

  Future<List<ReminderDto>> getReminders(
    String personUnderCareId, {
    String? from,
    String? to,
    String? type,
  }) async {
    final query = Uri(queryParameters: {'from': ?from, 'to': ?to, 'type': ?type}).query;
    final path = 'reminders/citizen/$personUnderCareId';
    final List jsons = await client.get(query.isEmpty ? path : '$path?$query');
    return jsons.map((json) => ReminderDto.fromJson(json)).toList();
  }

  Future<ReminderDto> scheduleReminder(ScheduleReminderRequestDto request) async {
    final json = await client.post('reminders', body: request.toJson());
    return ReminderDto.fromJson(json);
  }

  Future<ReminderDto> confirmReminder(String reminderId) async {
    final json = await client.put('reminders/$reminderId/confirm');
    return ReminderDto.fromJson(json);
  }

  Future<ReminderDto> markReminderAsMissed(String reminderId) async {
    final json = await client.put('reminders/$reminderId/miss');
    return ReminderDto.fromJson(json);
  }

  Future<ReminderDto> cancelReminder(String reminderId) async {
    final json = await client.delete('reminders/$reminderId');
    return ReminderDto.fromJson(json);
  }
}
