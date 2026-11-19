import 'package:guardian_plus_app/core/network/api_client.dart';

/// Raw REST access of the mobility_geofencing contract. `ApiClient` already carries the `/api/v1/` base.
class MobilityGeofencingApi {
  final ApiClient client;

  const MobilityGeofencingApi({required this.client});

  // Location tracking (US-18)
  Future<dynamic> getCurrentLocation(String id) => client.get('location-tracking/$id/current');

  Future<dynamic> getLocationHistory(String id) => client.get('location-tracking/$id/history');

  Future<dynamic> getMobilityStatus(String id) => client.get('location-tracking/$id/status');

  // Safe zones (EP04)
  Future<dynamic> getSafeZones(String id) => client.get('safe-zones/fragile-citizen/$id');

  Future<dynamic> createSafeZone(Map<String, dynamic> body) => client.post('safe-zones', body: body);

  Future<dynamic> updateSafeZone(String zoneId, Map<String, dynamic> body) =>
      client.put('safe-zones/$zoneId', body: body);

  Future<dynamic> deleteSafeZone(String zoneId) => client.delete('safe-zones/$zoneId');

  Future<dynamic> activateSafeZone(String zoneId) => client.patch('safe-zones/$zoneId/activate');

  Future<dynamic> deactivateSafeZone(String zoneId) => client.patch('safe-zones/$zoneId/deactivate');

  // Direct communication (US-23)
  Future<dynamic> getDeviceCapabilities(String id) => client.get('communication/$id/device-capabilities');

  Future<dynamic> startCall(Map<String, dynamic> body) => client.post('communication/calls/start', body: body);

  Future<dynamic> endCall(String callId) => client.post('communication/calls/$callId/end');

  Future<dynamic> logUnanswered(Map<String, dynamic> body) =>
      client.post('communication/calls/log-unanswered', body: body);

  Future<dynamic> getCallLogs(String id) => client.get('communication/$id/call-logs');

  Future<dynamic> sendHapticAlert(Map<String, dynamic> body) => client.post('communication/haptic-alert', body: body);
}
