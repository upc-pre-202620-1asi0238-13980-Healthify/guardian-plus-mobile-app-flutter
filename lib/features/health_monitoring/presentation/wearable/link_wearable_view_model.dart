import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/link_wearable_device_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/device_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/link_wearable_state.dart';

/// Links a wearable to the care recipient of the signed-in account.
class LinkWearableViewModel extends ChangeNotifier {
  final LinkWearableDeviceUseCase linkWearableDevice;
  final CareContextStore careContextStore;

  new({required this.linkWearableDevice, required this.careContextStore});

  LinkWearableState _state = const LinkWearableState();
  LinkWearableState get state => _state;

  bool _disposed = false;

  void onSerialNumberChange(String value) {
    _emit(_state.copyWith(serialNumber: value, errorMessage: () => null));
  }

  void onDeviceTypeChange(DeviceType value) {
    _emit(_state.copyWith(deviceType: value));
  }

  Future<void> link() async {
    if (_state.isLoading) return;
    if (_state.serialNumber.trim().isEmpty) {
      _emit(_state.copyWith(errorMessage: () => 'Ingresa el número de serie del dispositivo'));
      return;
    }
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    try {
      await linkWearableDevice.execute(
        careRecipientProfileId: careContextStore.require().careRecipientProfileId,
        serialNumber: _state.serialNumber,
        deviceType: _state.deviceType,
      );
      _emit(_state.copyWith(isLoading: false, isLinked: true));
    } catch (e) {
      // A serial number already linked (409) comes back with the platform's own message
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => e is ApiException ? e.message : 'No se pudo vincular el dispositivo',
      ));
    }
  }

  void _emit(LinkWearableState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
