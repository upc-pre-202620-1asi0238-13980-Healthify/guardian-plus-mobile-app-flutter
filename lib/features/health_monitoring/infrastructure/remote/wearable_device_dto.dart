/// A wearable device as the platform sends it (WearableDeviceResource).
class WearableDeviceDto {
  final String id;
  final String careRecipientProfileId;
  final String serialNumber;
  final String deviceType;
  final String linkedAt;

  const new({
    required this.id,
    required this.careRecipientProfileId,
    required this.serialNumber,
    required this.deviceType,
    required this.linkedAt,
  });

  factory WearableDeviceDto.fromJson(Map<String, dynamic> json) {
    return WearableDeviceDto(
      id: json['id'],
      careRecipientProfileId: json['careRecipientProfileId'],
      serialNumber: json['serialNumber'],
      deviceType: json['deviceType'],
      linkedAt: json['linkedAt'],
    );
  }
}
