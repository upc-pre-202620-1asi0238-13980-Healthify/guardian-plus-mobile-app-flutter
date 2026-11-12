/// Same body as the platform's ConfirmMedicationAcquisitionResource; without dosesAdded a whole package is added.
class ConfirmMedicationAcquisitionRequestDto {
  final int? dosesAdded;

  const new({this.dosesAdded});

  Map<String, dynamic> toJson() {
    return {'dosesAdded': ?dosesAdded};
  }
}
