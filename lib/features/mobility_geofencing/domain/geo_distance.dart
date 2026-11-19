import 'dart:math' as math;

const _earthRadiusMeters = 6371008.8;

/// Great-circle distance in meters between two coordinates (haversine).
double distanceInMeters(double lat1, double lon1, double lat2, double lon2) {
  double rad(double degrees) => degrees * math.pi / 180;

  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) + math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * _earthRadiusMeters * math.asin(math.min(1, math.sqrt(a)));
}
