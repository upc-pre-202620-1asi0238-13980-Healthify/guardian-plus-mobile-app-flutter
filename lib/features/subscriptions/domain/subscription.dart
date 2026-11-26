class Subscription {
  final String id;
  final String subscriberId;
  final String planId;
  final String status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.subscriberId,
    required this.planId,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  bool get isPending => status.toUpperCase() == 'PENDING';

  bool get isCancellationScheduled =>
      status.toUpperCase() == 'CANCELLATION_SCHEDULED' || cancelAtPeriodEnd;

  bool get canRequestCancellation => isActive && !cancelAtPeriodEnd;

  bool get canRequestRenewal =>
      isActive && !cancelAtPeriodEnd && currentPeriodEnd != null;
}

class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String billingCycle;
  final bool active;
  final bool requiresPayment;
  final List<String> entitlementCodes;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.active,
    required this.requiresPayment,
    required this.entitlementCodes,
  });

  bool get isFree => !requiresPayment;

  bool get isMonthly => billingCycle == 'MONTHLY';

  bool get isAnnual => billingCycle == 'ANNUAL';
}

class PaymentInitiation {
  final String provider;
  final String externalReference;
  final String status;
  final String? clientSecret;

  const PaymentInitiation({
    required this.provider,
    required this.externalReference,
    required this.status,
    this.clientSecret,
  });

  bool get isPending => status.toUpperCase() == 'PENDING';

  bool get isConfirmed => status.toUpperCase() == 'CONFIRMED';

  bool get isFailed => status.toUpperCase() == 'FAILED';

  bool get isStripe => provider == 'stripe';

  bool get canPresentPaymentSheet =>
      isStripe && isPending && clientSecret != null && clientSecret!.isNotEmpty;
}

class Entitlement {
  final String code;
  final String name;
  final String description;

  const Entitlement({
    required this.code,
    required this.name,
    required this.description,
  });
}

class SubscriptionSummary {
  final Subscription subscription;
  final List<Entitlement> entitlements;

  const SubscriptionSummary({
    required this.subscription,
    required this.entitlements,
  });

  bool hasEntitlement(String code) {
    return entitlements.any((entitlement) => entitlement.code == code);
  }

  SubscriptionSummary copyWith({
    Subscription? subscription,
    List<Entitlement>? entitlements,
  }) {
    return SubscriptionSummary(
      subscription: subscription ?? this.subscription,
      entitlements: entitlements ?? this.entitlements,
    );
  }
}
