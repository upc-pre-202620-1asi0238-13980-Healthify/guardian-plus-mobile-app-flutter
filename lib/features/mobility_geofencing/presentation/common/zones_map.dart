import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/location_reading.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';
import 'package:latlong2/latlong.dart';

/// OpenStreetMap with the safe zones as circles (real radius in meters) and the care recipient's position.
/// Everything drawn comes from the arguments; with nothing to center on it shows [emptyMessage] instead.
class ZonesMap extends StatelessWidget {
  final List<SafeZone> zones;
  final LocationReading? location;
  final LatLng? focus;
  final String? highlightZoneId;
  final void Function(LatLng point)? onTap;
  final double height;
  final double zoom;
  final String emptyMessage;
  final bool outside;

  const ZonesMap({
    super.key,
    required this.zones,
    required this.emptyMessage,
    this.location,
    this.focus,
    this.highlightZoneId,
    this.onTap,
    this.height = 240,
    this.zoom = 15,
    this.outside = false,
  });

  LatLng? get _center {
    if (focus != null) return focus;
    final reading = location;
    if (reading != null) return LatLng(reading.latitude, reading.longitude);
    final zone = zones.where((zone) => zone.isActive).firstOrNull ?? zones.firstOrNull;
    return zone == null ? null : LatLng(zone.latitude, zone.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final center = _center;

    if (center == null) {
      return Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
        child: Text(emptyMessage, textAlign: TextAlign.center),
      );
    }

    final reading = location;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          key: ValueKey('${center.latitude},${center.longitude},$zoom'),
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            onTap: onTap == null ? null : (_, point) => onTap!(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'guardian_plus_app',
            ),
            CircleLayer(
              circles: [
                for (final zone in zones)
                  CircleMarker(
                    point: LatLng(zone.latitude, zone.longitude),
                    radius: zone.radiusMeters,
                    useRadiusInMeter: true,
                    color: (zone.isActive ? colors.primary : colors.outline).withValues(
                      alpha: zone.id == highlightZoneId ? 0.28 : 0.14,
                    ),
                    borderColor: zone.isActive ? colors.primary : colors.outline,
                    borderStrokeWidth: zone.id == highlightZoneId ? 3 : 1.5,
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                if (reading != null)
                  Marker(
                    point: LatLng(reading.latitude, reading.longitude),
                    width: 44,
                    height: 44,
                    child: Icon(Icons.person_pin_circle, size: 40, color: outside ? colors.error : colors.primary),
                  ),
                if (focus != null && onTap != null)
                  Marker(point: focus!, width: 36, height: 36, child: Icon(Icons.place, size: 34, color: colors.tertiary)),
              ],
            ),
            const SimpleAttributionWidget(source: Text('OpenStreetMap')),
          ],
        ),
      ),
    );
  }
}
