/// One reading of the live view as the platform sends it (LiveVitalSignResource).
class LiveVitalSignDto {
  final String vitalSignId;
  final String vitalSignType;
  final String vitalSignTypeName;
  final String unit;
  final double value;
  final String measuredAt;
  final double normalMinimum;
  final double normalMaximum;
  final String classification;
  final bool liveSignal;

  const new({
    required this.vitalSignId,
    required this.vitalSignType,
    required this.vitalSignTypeName,
    required this.unit,
    required this.value,
    required this.measuredAt,
    required this.normalMinimum,
    required this.normalMaximum,
    required this.classification,
    required this.liveSignal,
  });

  factory LiveVitalSignDto.fromJson(Map<String, dynamic> json) {
    return LiveVitalSignDto(
      vitalSignId: json['vitalSignId'],
      vitalSignType: json['vitalSignType'],
      vitalSignTypeName: json['vitalSignTypeName'],
      unit: json['unit'],
      value: (json['value'] as num).toDouble(),
      measuredAt: json['measuredAt'],
      normalMinimum: (json['normalMinimum'] as num).toDouble(),
      normalMaximum: (json['normalMaximum'] as num).toDouble(),
      classification: json['classification'],
      liveSignal: json['liveSignal'],
    );
  }
}
