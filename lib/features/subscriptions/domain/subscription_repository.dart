import 'package:guardian_plus_app/features/subscriptions/domain/subscription.dart';

abstract interface class SubscriptionRepository {
  Future<SubscriptionSummary?> getCurrentSubscription(String subscriberId);

  Future<Subscription> requestCancellation(String subscriptionId);
}
