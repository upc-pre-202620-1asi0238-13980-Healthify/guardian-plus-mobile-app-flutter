import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/get_live_vital_signs_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/get_vital_sign_history_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_filter.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/vital_history/vital_history_state.dart';

/// "Salud › Historial": the readings of the chosen period and the normal ranges to judge them.
class VitalHistoryViewModel extends ChangeNotifier {
  final GetVitalSignHistoryUseCase getVitalSignHistory;
  final GetLiveVitalSignsUseCase getLiveVitalSigns;
  final CareContextStore careContextStore;

  new({required this.getVitalSignHistory, required this.getLiveVitalSigns, required this.careContextStore}) {
    load();
  }

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  VitalHistoryState _state = VitalHistoryState(today: DateUtils.dateOnly(DateTime.now()));
  VitalHistoryState get state => _state;

  // A newer period replaces a load still running, so an older answer cannot land on top of it
  int _loadId = 0;
  bool _disposed = false;

  Future<void> load() async {
    final loadId = ++_loadId;
    final period = _state.filter.period;
    final today = DateUtils.dateOnly(DateTime.now());
    final careRecipientId = _careContext.careRecipientProfileId;
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));

    // Ranges only colour the badges; without them the history still makes sense
    Map<VitalSignType, NormalRange> ranges;
    try {
      final live = await getLiveVitalSigns.execute(careRecipientId);
      ranges = {for (final sign in live.vitalSigns) sign.type: (min: sign.normalMinimum, max: sign.normalMaximum)};
    } catch (_) {
      ranges = const {};
    }

    try {
      // The platform filters by UTC date while the period is drawn on Lima's calendar (UTC−5), so one extra
      // day is asked on each side and the state keeps only the readings that fall inside the local period
      final readings = await getVitalSignHistory.execute(
        careRecipientId,
        from: DateTime(today.year, today.month, today.day - period.dayCount),
        to: DateTime(today.year, today.month, today.day + 1),
      );
      if (loadId != _loadId) return;
      _emit(_state.copyWith(isLoading: false, readings: readings, ranges: ranges, period: period, today: today));
    } catch (e) {
      if (loadId != _loadId) return;
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => e is ApiException ? e.message : 'No se pudo cargar el historial',
      ));
    }
  }

  // Every type of the period is already loaded, so switching is local
  void selectType(VitalSignType type) {
    _emit(_state.copyWith(selectedType: type));
  }

  // Every type of the period is already loaded, so only a new period goes back to the platform
  void applyFilter(VitalFilter filter) {
    final previous = _state.filter;
    _emit(_state.copyWith(filter: filter));
    if (filter.period != previous.period) load();
  }

  void _emit(VitalHistoryState state) {
    // A request can finish after the user has left the screen
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
