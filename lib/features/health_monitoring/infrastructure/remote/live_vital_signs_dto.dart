import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/live_vital_sign_dto.dart';

/// Live view of the vital signs of a care recipient (LiveVitalSignsResource).
class LiveVitalSignsDto {
  final String careRecipientProfileId;
  final String retrievedAt;
  final List<LiveVitalSignDto> vitalSigns;

  const new({required this.careRecipientProfileId, required this.retrievedAt, required this.vitalSigns});

  factory LiveVitalSignsDto.fromJson(Map<String, dynamic> json) {
    final List signs = json['vitalSigns'];
    return LiveVitalSignsDto(
      careRecipientProfileId: json['careRecipientProfileId'],
      retrievedAt: json['retrievedAt'],
      vitalSigns: signs.map((sign) => LiveVitalSignDto.fromJson(sign)).toList(),
    );
  }
}
