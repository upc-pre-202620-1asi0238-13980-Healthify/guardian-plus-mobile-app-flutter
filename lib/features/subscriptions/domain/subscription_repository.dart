import 'package:guardian_plus_app/features/subscriptions/domain/subscription.dart';

abstract interface class SubscriptionRepository {
  Future<List<SubscriptionPlan>> getPlans();

  Future<SubscriptionSummary?> getCurrentSubscription(String subscriberId);

  Future<Subscription> requestSubscription({
    required String subscriberId,
    required String planId,
  });

  Future<PaymentInitiation> initiateActivationPayment(String subscriptionId);

  Future<PaymentInitiation> initiateRenewalPayment(String subscriptionId);

  Future<Subscription> changePlan({
    required String subscriptionId,
    required String newPlanId,
  });

  Future<Subscription> requestCancellation(String subscriptionId);
}
