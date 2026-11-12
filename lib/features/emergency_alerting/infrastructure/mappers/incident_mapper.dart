import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/mappers/api_enum_mapper.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/incident_dto.dart';

extension IncidentDtoMapper on IncidentDto {
  Incident toDomain() {
    return Incident(
      id: id,
      alertId: alertId,
      status: enumFromApi(IncidentStatus.values, status),
      markedInAttentionAt: DateTime.parse(markedInAttentionAt),
      stabilizedAt: stabilizedAt == null ? null : DateTime.parse(stabilizedAt!),
      closedAt: closedAt == null ? null : DateTime.parse(closedAt!),
      notes: notes,
    );
  }
}
