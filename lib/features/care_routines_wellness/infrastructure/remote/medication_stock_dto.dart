/// The stock of one medication as the platform sends it (MedicationStockResource).
class MedicationStockDto {
  final String id;
  final String personUnderCareId;
  final String medicationName;
  final String? dosage;
  final int remainingDoses;
  final double dailyConsumption;
  final int packageSize;
  final String? lastAcquisitionDate;
  final double remainingDaysOfSupply;
  final String? estimatedDepletionDate;
  final bool restockRecommended;

  const new({
    required this.id,
    required this.personUnderCareId,
    required this.medicationName,
    required this.dosage,
    required this.remainingDoses,
    required this.dailyConsumption,
    required this.packageSize,
    required this.lastAcquisitionDate,
    required this.remainingDaysOfSupply,
    required this.estimatedDepletionDate,
    required this.restockRecommended,
  });

  factory MedicationStockDto.fromJson(Map<String, dynamic> json) {
    return MedicationStockDto(
      id: json['id'],
      personUnderCareId: json['personUnderCareId'],
      medicationName: json['medicationName'],
      dosage: json['dosage'],
      remainingDoses: json['remainingDoses'],
      // JSON numbers without decimals arrive as int
      dailyConsumption: (json['dailyConsumption'] as num).toDouble(),
      packageSize: json['packageSize'],
      lastAcquisitionDate: json['lastAcquisitionDate'],
      remainingDaysOfSupply: (json['remainingDaysOfSupply'] as num).toDouble(),
      estimatedDepletionDate: json['estimatedDepletionDate'],
      restockRecommended: json['restockRecommended'],
    );
  }
}
