import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/device_type.dart';

class LinkWearableState {
  const new({
    this.serialNumber = '',
    this.deviceType = DeviceType.wristband,
    this.isLoading = false,
    this.errorMessage,
    this.isLinked = false,
  });

  final String serialNumber;
  final DeviceType deviceType;
  final bool isLoading;
  final String? errorMessage;
  // Set once the platform linked the device; the sheet closes
  final bool isLinked;

  LinkWearableState copyWith({
    String? serialNumber,
    DeviceType? deviceType,
    bool? isLoading,
    ValueGetter<String?>? errorMessage,
    bool? isLinked,
  }) {
    return LinkWearableState(
      serialNumber: serialNumber ?? this.serialNumber,
      deviceType: deviceType ?? this.deviceType,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isLinked: isLinked ?? this.isLinked,
    );
  }
}
