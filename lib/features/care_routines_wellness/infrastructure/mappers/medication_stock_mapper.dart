import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/medication_stock_dto.dart';

extension MedicationStockDtoMapper on MedicationStockDto {
  MedicationStock toDomain() {
    return MedicationStock(
      id: id,
      medicationName: medicationName,
      dosage: dosage,
      remainingDoses: remainingDoses,
      dailyConsumption: dailyConsumption,
      packageSize: packageSize,
      remainingDaysOfSupply: remainingDaysOfSupply,
      estimatedDepletionDate: estimatedDepletionDate != null ? DateTime.parse(estimatedDepletionDate!) : null,
      restockRecommended: restockRecommended,
    );
  }
}
