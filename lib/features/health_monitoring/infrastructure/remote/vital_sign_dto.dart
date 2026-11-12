/// A stored reading as the platform sends it (VitalSignResource).
class VitalSignDto {
  final String id;
  final String vitalSignType;
  final double value;
  final String measuredAt;

  const new({required this.id, required this.vitalSignType, required this.value, required this.measuredAt});

  factory VitalSignDto.fromJson(Map<String, dynamic> json) {
    return VitalSignDto(
      id: json['id'],
      vitalSignType: json['vitalSignType'],
      value: (json['value'] as num).toDouble(),
      measuredAt: json['measuredAt'],
    );
  }
}
