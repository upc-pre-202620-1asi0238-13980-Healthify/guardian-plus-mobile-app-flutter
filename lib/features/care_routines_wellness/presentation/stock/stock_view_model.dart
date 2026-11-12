import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/confirm_medication_acquisition_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_medication_stocks_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/stock/stock_state.dart';

/// "Stock de medicinas": doses left of each medication and how long they last.
class StockViewModel extends ChangeNotifier implements RoutineMessageSource {
  final GetMedicationStocksUseCase getMedicationStocks;
  final ConfirmMedicationAcquisitionUseCase confirmMedicationAcquisition;
  final CareContextStore careContextStore;

  new({required this.getMedicationStocks, required this.confirmMedicationAcquisition, required this.careContextStore}) {
    load();
  }

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  StockState _state = const StockState();
  StockState get state => _state;

  bool _disposed = false;

  @override
  String? get message => _state.message;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    try {
      final stocks = await getMedicationStocks.execute(_careContext.careRecipientProfileId);
      _emit(_state.copyWith(isLoading: false, isLoaded: true, stocks: stocks));
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => routineErrorMessage(e, 'No se pudo cargar el stock'),
      ));
    }
  }

  /// "Añadir envase": the platform adds a whole package and recalculates the days of supply.
  Future<void> addPackage(MedicationStock stock) async {
    if (_state.restockingId != null) return;
    _emit(_state.copyWith(restockingId: () => stock.id));
    try {
      final updated = await confirmMedicationAcquisition.execute(stock.id);
      _emit(_state.copyWith(
        stocks: [
          for (final current in _state.stocks) current.id == updated.id ? updated : current,
        ],
        message: () => 'Stock actualizado: se añadieron ${updated.remainingDoses - stock.remainingDoses} unidades',
      ));
    } catch (e) {
      _emit(_state.copyWith(message: () => routineErrorMessage(e, 'No se pudo añadir el envase')));
    }
    _emit(_state.copyWith(restockingId: () => null));
  }

  @override
  void onMessageShown() {
    _emit(_state.copyWith(message: () => null));
  }

  void _emit(StockState state) {
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
