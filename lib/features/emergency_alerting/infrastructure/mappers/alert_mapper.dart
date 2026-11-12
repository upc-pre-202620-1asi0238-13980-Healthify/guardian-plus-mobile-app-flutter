import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_delivery.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_response.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/delivery_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/response_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/mappers/api_enum_mapper.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_delivery_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_response_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_summary_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/page_dto.dart';

extension AlertSummaryDtoMapper on AlertSummaryDto {
  Alert toDomain() {
    return Alert(
      id: id,
      careRecipientProfileId: careRecipientProfileId,
      sourceType: enumFromApi(AlertSourceType.values, sourceType),
      severity: enumFromApi(Severity.values, severity),
      status: enumFromApi(AlertStatus.values, status),
      currentRecipientLevel: _recipientLevel(currentRecipientLevel),
      triggeredAt: DateTime.parse(triggeredAt),
      acknowledgedAt: _instant(acknowledgedAt),
    );
  }
}

extension AlertDtoMapper on AlertDto {
  Alert toDomain() {
    return Alert(
      id: id,
      careRecipientProfileId: careRecipientProfileId,
      sourceType: enumFromApi(AlertSourceType.values, sourceType),
      severity: enumFromApi(Severity.values, severity),
      status: enumFromApi(AlertStatus.values, status),
      currentRecipientLevel: _recipientLevel(currentRecipientLevel),
      triggeredAt: DateTime.parse(triggeredAt),
      acknowledgedAt: _instant(acknowledgedAt),
      confirmedAt: _instant(confirmedAt),
      lastDispatchedAt: _instant(lastDispatchedAt),
      acknowledgedByUserId: acknowledgedByUserId,
      resolvedAt: _instant(resolvedAt),
      deliveries: deliveries.map((dto) => dto.toDomain()).toList(),
      responses: responses.map((dto) => dto.toDomain()).toList(),
    );
  }
}

extension AlertDeliveryDtoMapper on AlertDeliveryDto {
  AlertDelivery toDomain() {
    return AlertDelivery(
      id: id,
      recipientUserId: recipientUserId,
      recipientLevel: enumFromApi(RecipientLevel.values, recipientLevel),
      channel: enumFromApi(NotificationChannel.values, channel),
      status: enumFromApi(DeliveryStatus.values, deliveryStatus),
      sentAt: _instant(sentAt),
      deliveredAt: _instant(deliveredAt),
    );
  }
}

extension AlertResponseDtoMapper on AlertResponseDto {
  AlertResponse toDomain() {
    return AlertResponse(
      id: id,
      responderUserId: responderUserId,
      status: enumFromApi(ResponseStatus.values, responseStatus),
      claimedAt: DateTime.parse(claimedAt),
      completedAt: _instant(completedAt),
      notes: notes,
    );
  }
}

extension AlertPageDtoMapper on PageDto<AlertSummaryDto> {
  AlertPage toDomain() {
    return AlertPage(
      alerts: content.map((dto) => dto.toDomain()).toList(),
      page: page,
      totalPages: totalPages,
      totalElements: totalElements,
    );
  }
}

RecipientLevel? _recipientLevel(String? value) => value == null ? null : enumFromApi(RecipientLevel.values, value);

// The platform sends instants in ISO 8601 with Z; they stay in UTC until the screen shows them
DateTime? _instant(String? value) => value == null ? null : DateTime.parse(value);
