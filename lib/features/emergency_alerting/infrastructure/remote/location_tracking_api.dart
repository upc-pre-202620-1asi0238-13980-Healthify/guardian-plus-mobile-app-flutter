import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/current_location_dto.dart';

/// Mobility & Geofencing's last known position of the person under care, read to show where an alert happened.
class LocationTrackingApi {
  final ApiClient client;

  const new({required this.client});

  // Mobility names the person under care "fragile citizen"; it is the care recipient profile id
  Future<CurrentLocationDto> getCurrentLocation(String careRecipientProfileId) async {
    final json = await client.get('location-tracking/$careRecipientProfileId/current');
    return CurrentLocationDto.fromJson(json);
  }
}
