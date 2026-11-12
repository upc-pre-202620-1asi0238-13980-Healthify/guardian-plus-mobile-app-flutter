import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/medication_stock_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/confirm_medication_acquisition_request_dto.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/medication_stock_api.dart';

class MedicationStockRepositoryImpl implements MedicationStockRepository {
  final MedicationStockApi api;

  const new({required this.api});

  @override
  Future<List<MedicationStock>> getMedicationStocks(String personUnderCareId) async {
    final dtos = await api.getMedicationStocks(personUnderCareId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<MedicationStock> confirmMedicationAcquisition(String medicationStockId) async {
    final dto = await api.confirmMedicationAcquisition(medicationStockId, const ConfirmMedicationAcquisitionRequestDto());
    return dto.toDomain();
  }
}
