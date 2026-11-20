import 'package:guardian_plus_app/core/network/api_client.dart';

class SubscriptionsApi {
  final ApiClient client;

  const SubscriptionsApi({required this.client});

  Future<Map<String, dynamic>> getCurrentSubscription(
    String subscriberId,
  ) async {
    final json = await client.get(
      'subscriptions/subscriber/$subscriberId/status',
    );

    return json as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getEntitlements(String subscriberId) async {
    final json = await client.get(
      'subscriptions/subscriber/$subscriberId/entitlements',
    );

    return json as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> requestCancellation(
    String subscriptionId,
  ) async {
    final json = await client.post(
      'subscriptions/$subscriptionId/cancellation',
    );

    return json as Map<String, dynamic>;
  }
}
