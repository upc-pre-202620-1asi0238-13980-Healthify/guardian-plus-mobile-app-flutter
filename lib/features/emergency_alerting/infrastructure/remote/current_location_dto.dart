/// Last known position of the person under care as Mobility & Geofencing sends it (LocationResource).
class CurrentLocationDto {
  final double? latitude;
  final double? longitude;
  final String? recordedAt;

  const new({this.latitude, this.longitude, this.recordedAt});

  factory CurrentLocationDto.fromJson(Map<String, dynamic> json) {
    return CurrentLocationDto(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      recordedAt: json['recordedAt'],
    );
  }
}
