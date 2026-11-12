import 'package:guardian_plus_app/features/health_monitoring/domain/device_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/reading_classification.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';

/// The platform names the vital sign types in upper snake case (HR, BP_SYS, SPO2…).
extension VitalSignTypeMapper on VitalSignType {
  String toApi() {
    return switch (this) {
      VitalSignType.hr => 'HR',
      VitalSignType.bpSys => 'BP_SYS',
      VitalSignType.bpDia => 'BP_DIA',
      VitalSignType.spo2 => 'SPO2',
      VitalSignType.temp => 'TEMP',
      VitalSignType.respRate => 'RESP_RATE',
    };
  }

  /// Null for a type the app does not know yet, so its readings are left out rather than failing the screen.
  static VitalSignType? tryFromApi(String value) {
    for (final type in VitalSignType.values) {
      if (type.toApi() == value) return type;
    }
    return null;
  }
}

extension ReadingClassificationMapper on ReadingClassification {
  String toApi() {
    return switch (this) {
      ReadingClassification.belowRange => 'BELOW_RANGE',
      ReadingClassification.withinRange => 'WITHIN_RANGE',
      ReadingClassification.aboveRange => 'ABOVE_RANGE',
    };
  }

  static ReadingClassification fromApi(String value) {
    return ReadingClassification.values.firstWhere(
      (classification) => classification.toApi() == value,
      orElse: () => throw FormatException('Unknown reading classification: $value'),
    );
  }
}

extension DeviceTypeMapper on DeviceType {
  String toApi() {
    return switch (this) {
      DeviceType.smartwatch => 'SMARTWATCH',
      DeviceType.wristband => 'WRISTBAND',
      DeviceType.patch => 'PATCH',
    };
  }

  static DeviceType fromApi(String value) {
    return DeviceType.values.firstWhere(
      (type) => type.toApi() == value,
      orElse: () => throw FormatException('Unknown device type: $value'),
    );
  }
}
