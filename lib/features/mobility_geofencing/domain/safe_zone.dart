/// A geofence the care recipient is expected to stay in ("zona segura").
class SafeZone {
  final String id;
  final String fragileCitizenId;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isActive;

  const SafeZone({
    required this.id,
    required this.fragileCitizenId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.isActive,
  });

  SafeZone copyWith({String? name, double? latitude, double? longitude, double? radiusMeters, bool? isActive}) {
    return SafeZone(
      id: id,
      fragileCitizenId: fragileCitizenId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Data needed to create or update a safe zone.
class SafeZoneDraft {
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  const SafeZoneDraft({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });
}
