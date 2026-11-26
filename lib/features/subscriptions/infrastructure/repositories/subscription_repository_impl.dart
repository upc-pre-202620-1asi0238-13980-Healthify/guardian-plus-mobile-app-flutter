import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription_repository.dart';
import 'package:guardian_plus_app/features/subscriptions/infrastructure/remote/subscriptions_api.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionsApi api;

  const SubscriptionRepositoryImpl({required this.api});

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    final json = await api.getPlans();

    final plans = json.map(_planFromJson).where((plan) => plan.active).toList();

    plans.sort((first, second) {
      return first.price.compareTo(second.price);
    });

    return List.unmodifiable(plans);
  }

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

    final subscription = _subscriptionFromJson(subscriptionJson);

    if (subscription.isPending) {
      return SubscriptionSummary(
        subscription: subscription,
        entitlements: const [],
      );
    }

    List<Entitlement> entitlements = const [];

    try {
      final json = await api.getEntitlements(subscriberId);

      final entitlementSubscriptionId = json['subscriptionId']?.toString();

      if (entitlementSubscriptionId != null &&
          entitlementSubscriptionId != subscription.id) {
        throw const ApiException(
          'Subscription changed while loading entitlements',
        );
      }

      final items = json['entitlements'];

      if (items is List) {
        entitlements = items
            .map((item) {
              final map = item as Map<String, dynamic>;

              return Entitlement(
                code: map['code']?.toString() ?? '',
                name: map['name']?.toString() ?? '',
                description: map['description']?.toString() ?? '',
              );
            })
            .toList(growable: false);
      }
    } on ApiException catch (error) {
      if (error.statusCode != 404) {
        rethrow;
      }
    }

    return SubscriptionSummary(
      subscription: subscription,
      entitlements: List.unmodifiable(entitlements),
    );
  }

  @override
  Future<Subscription> requestSubscription({
    required String subscriberId,
    required String planId,
  }) async {
    final json = await api.requestSubscription(
      subscriberId: subscriberId,
      planId: planId,
    );

    return _subscriptionFromJson(json);
  }

  @override
  Future<PaymentInitiation> initiateActivationPayment(
    String subscriptionId,
  ) async {
    final json = await api.initiateActivationPayment(subscriptionId);

    return _paymentFromJson(json);
  }

  @override
  Future<PaymentInitiation> initiateRenewalPayment(
    String subscriptionId,
  ) async {
    final json = await api.initiateRenewalPayment(subscriptionId);

    return _paymentFromJson(json);
  }

  @override
  Future<Subscription> changePlan({
    required String subscriptionId,
    required String newPlanId,
  }) async {
    final json = await api.changePlan(
      subscriptionId: subscriptionId,
      newPlanId: newPlanId,
    );

    return _subscriptionFromJson(json);
  }

  @override
  Future<Subscription> requestCancellation(String subscriptionId) async {
    final json = await api.requestCancellation(subscriptionId);

    return _subscriptionFromJson(json);
  }

  SubscriptionPlan _planFromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      billingCycle: json['billingCycle'] as String,
      active: json['active'] == true,
      requiresPayment: json['requiresPayment'] == true,
      entitlementCodes: List<String>.unmodifiable(
        (json['entitlementCodes'] as List).cast<String>(),
      ),
    );
  }

  PaymentInitiation _paymentFromJson(Map<String, dynamic> json) {
    return PaymentInitiation(
      provider: json['provider'] as String,
      externalReference: json['externalReference'] as String,
      status: json['status'] as String,
      clientSecret: json['clientSecret'] as String?,
    );
  }

  Subscription _subscriptionFromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      subscriberId: json['subscriberId'] as String,
      planId: json['planId'] as String,
      status: json['status'] as String,
      currentPeriodStart: _nullableDate(json['currentPeriodStart']),
      currentPeriodEnd: _nullableDate(json['currentPeriodEnd']),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] == true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  DateTime? _nullableDate(Object? value) {
    return value == null ? null : DateTime.parse(value as String);
  }
}
