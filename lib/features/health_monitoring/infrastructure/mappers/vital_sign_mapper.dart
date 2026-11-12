import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_sign.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_signs.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_reading.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/mappers/vital_sign_enums_mapper.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/live_vital_sign_dto.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/live_vital_signs_dto.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/vital_sign_dto.dart';

extension LiveVitalSignsDtoMapper on LiveVitalSignsDto {
  LiveVitalSigns toDomain() {
    return LiveVitalSigns(
      careRecipientProfileId: careRecipientProfileId,
      retrievedAt: DateTime.parse(retrievedAt).toLocal(),
      vitalSigns: vitalSigns.map((sign) => sign.toDomainOrNull()).nonNulls.toList(),
    );
  }
}

extension LiveVitalSignDtoMapper on LiveVitalSignDto {
  LiveVitalSign? toDomainOrNull() {
    final type = VitalSignTypeMapper.tryFromApi(vitalSignType);
    if (type == null) return null;
    return LiveVitalSign(
      id: vitalSignId,
      type: type,
      typeName: vitalSignTypeName,
      unit: unit,
      value: value,
      measuredAt: DateTime.parse(measuredAt).toLocal(),
      normalMinimum: normalMinimum,
      normalMaximum: normalMaximum,
      classification: ReadingClassificationMapper.fromApi(classification),
      liveSignal: liveSignal,
    );
  }
}

extension VitalSignDtoMapper on VitalSignDto {
  VitalSignReading? toDomainOrNull() {
    final type = VitalSignTypeMapper.tryFromApi(vitalSignType);
    if (type == null) return null;
    return VitalSignReading(id: id, type: type, value: value, measuredAt: DateTime.parse(measuredAt).toLocal());
  }
}
