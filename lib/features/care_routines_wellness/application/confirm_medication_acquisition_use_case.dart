import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock_repository.dart';

/// "Añadir envase": a whole package is added to the remaining doses.
class ConfirmMedicationAcquisitionUseCase {
  final MedicationStockRepository repository;

  const new({required this.repository});

  Future<MedicationStock> execute(String medicationStockId) {
    return repository.confirmMedicationAcquisition(medicationStockId);
  }
}
