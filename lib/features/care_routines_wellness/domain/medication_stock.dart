/// Doses left of one medication and how long they last at the current consumption.
class MedicationStock {
  final String id;
  final String medicationName;
  final String? dosage;
  final int remainingDoses;
  final double dailyConsumption;
  // Doses added by each "Añadir envase"
  final int packageSize;
  final double remainingDaysOfSupply;
  final DateTime? estimatedDepletionDate;
  final bool restockRecommended;

  const new({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.remainingDoses,
    required this.dailyConsumption,
    required this.packageSize,
    required this.remainingDaysOfSupply,
    required this.estimatedDepletionDate,
    required this.restockRecommended,
  });

  /// Remaining doses against a full package, capped at 100 % after several packages.
  int get packagePercentage {
    if (packageSize <= 0) return 0;
    return (remainingDoses * 100 ~/ packageSize).clamp(0, 100);
  }
}