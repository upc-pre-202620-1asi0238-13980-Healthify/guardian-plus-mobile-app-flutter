/// LinkWearableDeviceResource of the platform; deviceType is SMARTWATCH, WRISTBAND or PATCH.
class LinkWearableDeviceRequestDto {
  final String careRecipientProfileId;
  final String serialNumber;
  final String deviceType;

  const new({required this.careRecipientProfileId, required this.serialNumber, required this.deviceType});

  Map<String, dynamic> toJson() {
    return {'careRecipientProfileId': careRecipientProfileId, 'serialNumber': serialNumber, 'deviceType': deviceType};
  }
}
