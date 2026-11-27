import 'dart:ui';

import 'package:geocoding/geocoding.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/location/place_name_resolver.dart';

/// Resolves place names with the phone's geocoder, which needs no API key. The alert detail reads the context
/// again every few seconds, so names are kept per ~10 m cell instead of asking the geocoder each time.
class GeocoderPlaceNameResolver implements PlaceNameResolver {
  // Created on first use: the plugin is only there on a device, not in tests
  late final Geocoding _geocoding = Geocoding(locale: const Locale('es', 'PE'));
  final Map<(int, int), String> _names = {};

  static const _cellsPerDegree = 10000.0;

  @override
  Future<String?> nameOf(double latitude, double longitude) async {
    final cell = ((latitude * _cellsPerDegree).round(), (longitude * _cellsPerDegree).round());
    final known = _names[cell];
    if (known != null) return known;
    try {
      if (!await _geocoding.isPresent()) return null;
      final placemarks = await _geocoding.placemarkFromCoordinates(latitude, longitude);
      final name = placemarks.isEmpty ? null : placeNameOf(placemarks.first);
      if (name != null) _names[cell] = name;
      return name;
    } catch (_) {
      // No network or no geocoder: the screen shows the coordinates instead
      return null;
    }
  }
}

/// "Av. Larco 345 · Miraflores": the street first, then the district.
String? placeNameOf(Placemark placemark) {
  final streetParts = [placemark.thoroughfare, placemark.subThoroughfare].where(_isPresent).join(' ');
  final street = streetParts.isNotEmpty ? streetParts : placemark.name;
  final district = _isPresent(placemark.subLocality) ? placemark.subLocality : placemark.locality;
  final parts = <String>{?_presentOrNull(street), ?_presentOrNull(district)};
  return parts.isEmpty ? null : parts.join(' · ');
}

bool _isPresent(String? value) => value != null && value.trim().isNotEmpty;

String? _presentOrNull(String? value) => _isPresent(value) ? value!.trim() : null;
