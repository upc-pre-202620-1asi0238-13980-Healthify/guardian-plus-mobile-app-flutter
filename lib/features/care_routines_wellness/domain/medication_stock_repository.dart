import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock.dart';

abstract class MedicationStockRepository {
  Future<List<MedicationStock>> getMedicationStocks(String personUnderCareId);

  /// "Añadir envase": a whole package is added to the remaining doses.
  Future<MedicationStock> confirmMedicationAcquisition(String medicationStockId);
}