import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device.dart';

class WearableDetailsState {
  const new({this.careRecipientName = '', this.wearable, this.isLoading = true, this.errorMessage});

  final String careRecipientName;
  final WearableDevice? wearable;
  final bool isLoading;
  final String? errorMessage;

  // Nullable fields take a function, so copyWith can also set them back to null
  WearableDetailsState copyWith({
    ValueGetter<WearableDevice?>? wearable,
    bool? isLoading,
    ValueGetter<String?>? errorMessage,
  }) {
    return WearableDetailsState(
      careRecipientName: careRecipientName,
      wearable: wearable != null ? wearable() : this.wearable,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
