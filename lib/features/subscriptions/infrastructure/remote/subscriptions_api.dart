import 'package:guardian_plus_app/core/network/api_client.dart';

class SubscriptionsApi {
  final ApiClient client;

  const SubscriptionsApi({required this.client});

  Future<List<Map<String, dynamic>>> getPlans() async {
    final json = await client.get('subscriptions/plans');

    final Object? items = json is Map ? json['value'] : json;

    if (items is! List) {
      throw const FormatException('Invalid subscription plans response');
    }

    return items
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

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

  Future<Map<String, dynamic>> requestSubscription({
    required String subscriberId,
    required String planId,
  }) async {
    final json = await client.post(
      'subscriptions',
      body: {'subscriberId': subscriberId, 'planId': planId},
    );

    return json as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> initiateActivationPayment(
    String subscriptionId,
  ) async {
    final json = await client.post('subscriptions/$subscriptionId/payment');

    return json as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> initiateRenewalPayment(
    String subscriptionId,
  ) async {
    final json = await client.post(
      'subscriptions/$subscriptionId/renewal/payment',
    );

    return json as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> changePlan({
    required String subscriptionId,
    required String newPlanId,
  }) async {
    final json = await client.patch(
      'subscriptions/$subscriptionId/plan',
      body: {'newPlanId': newPlanId},
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
