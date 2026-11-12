import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock_repository.dart';

class GetMedicationStocksUseCase {
  final MedicationStockRepository repository;

  const new({required this.repository});

  Future<List<MedicationStock>> execute(String personUnderCareId) {
    return repository.getMedicationStocks(personUnderCareId);
  }
}
