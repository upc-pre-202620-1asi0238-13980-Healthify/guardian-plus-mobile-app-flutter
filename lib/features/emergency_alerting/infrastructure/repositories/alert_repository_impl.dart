import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/mappers/alert_mapper.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/mappers/api_enum_mapper.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/acknowledge_alert_request_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/claim_alert_response_request_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/notes_request_dto.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertApi api;

  const new({required this.api});

  @override
  Future<AlertPage> getAlertHistory({
    required String careRecipientProfileId,
    Severity? severity,
    DateTime? from,
    DateTime? to,
    required int page,
    required int size,
  }) async {
    final dto = await api.getAlertHistory(
      careRecipientProfileId: careRecipientProfileId,
      severity: severity == null ? null : enumToApi(severity),
      from: from?.toUtc().toIso8601String(),
      to: to?.toUtc().toIso8601String(),
      page: page,
      size: size,
    );
    return dto.toDomain();
  }

  @override
  Future<List<Alert>> getActiveAlerts(String careRecipientProfileId) async {
    final dtos = await api.getActiveAlerts(careRecipientProfileId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<Alert>> getPendingAlerts(String userId) async {
    final dtos = await api.getPendingAlerts(userId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Alert> getAlertById(String alertId) async {
    final dto = await api.getAlertById(alertId);
    return dto.toDomain();
  }

  @override
  Future<Alert> acknowledgeAlert({required String alertId, required String userId}) async {
    final dto = await api.acknowledgeAlert(alertId, AcknowledgeAlertRequestDto(userId: userId));
    return dto.toDomain();
  }

  @override
  Future<Alert> claimAlertResponse({required String alertId, required String responderUserId}) async {
    final dto = await api.claimAlertResponse(alertId, ClaimAlertResponseRequestDto(responderUserId: responderUserId));
    return dto.toDomain();
  }

  @override
  Future<Alert> completeAlertResponse({required String alertId, required String responseId, String? notes}) async {
    final dto = await api.completeAlertResponse(alertId, responseId, NotesRequestDto(notes: notes));
    return dto.toDomain();
  }
}
