import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/get_wearable_devices_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/device_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/wearable_details_state.dart';

/// "Pulsera": the wearable linked to the care recipient, the wristband first.
class WearableDetailsViewModel extends ChangeNotifier {
  final GetWearableDevicesUseCase getWearableDevices;
  final CareContextStore careContextStore;

  new({required this.getWearableDevices, required this.careContextStore}) {
    load();
  }

  late final CareContext _careContext = careContextStore.require();

  late WearableDetailsState _state = WearableDetailsState(careRecipientName: _careContext.careRecipientName);
  WearableDetailsState get state => _state;

  CareContext get careContext => _careContext;

  bool _disposed = false;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    try {
      final devices = await getWearableDevices.execute(_careContext.careRecipientProfileId);
      final wearable =
          devices.where((device) => device.deviceType == DeviceType.wristband).firstOrNull ?? devices.firstOrNull;
      _emit(_state.copyWith(isLoading: false, wearable: () => wearable));
    } catch (_) {
      _emit(_state.copyWith(isLoading: false, errorMessage: () => 'No se pudo cargar el dispositivo'));
    }
  }

  void _emit(WearableDetailsState state) {
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
