import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription_repository.dart';
import 'package:guardian_plus_app/features/subscriptions/infrastructure/remote/subscriptions_api.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionsApi api;

  const SubscriptionRepositoryImpl({required this.api});

  @override
  Future<SubscriptionSummary?> getCurrentSubscription(
    String subscriberId,
  ) async {
    final Map<String, dynamic> subscriptionJson;

    try {
      subscriptionJson = await api.getCurrentSubscription(subscriberId);
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return null;
      }

      rethrow;
    }

    List<Entitlement> entitlements = const [];

    try {
      final json = await api.getEntitlements(subscriberId);
      final items = json['entitlements'];

      if (items is List) {
        entitlements = items.map((item) {
          final map = item as Map<String, dynamic>;

          return Entitlement(
            code: map['code']?.toString() ?? '',
            name: map['name']?.toString() ?? '',
            description: map['description']?.toString() ?? '',
          );
        }).toList();
      }
    } on ApiException catch (error) {
      if (error.statusCode != 404) {
        rethrow;
      }
    }

    return SubscriptionSummary(
      subscription: _subscriptionFromJson(subscriptionJson),
      entitlements: entitlements,
    );
  }

  @override
  Future<Subscription> requestCancellation(String subscriptionId) async {
    final json = await api.requestCancellation(subscriptionId);

    return _subscriptionFromJson(json);
  }

  Subscription _subscriptionFromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'].toString(),
      subscriberId: json['subscriberId'].toString(),
      planId: json['planId'].toString(),
      status: json['status'].toString(),
      currentPeriodStart: DateTime.parse(json['currentPeriodStart'].toString()),
      currentPeriodEnd: DateTime.parse(json['currentPeriodEnd'].toString()),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] == true,
      createdAt: DateTime.parse(json['createdAt'].toString()),
      updatedAt: DateTime.parse(json['updatedAt'].toString()),
    );
  }
}
