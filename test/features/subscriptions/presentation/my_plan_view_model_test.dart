import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription_repository.dart';
import 'package:guardian_plus_app/features/subscriptions/infrastructure/payments/stripe_payment_service.dart';
import 'package:guardian_plus_app/features/subscriptions/presentation/my_plan/my_plan_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const basic = SubscriptionPlan(
  id: 'basic',
  name: 'Guardian Basic',
  price: 0,
  currency: 'PEN',
  billingCycle: 'MONTHLY',
  active: true,
  requiresPayment: false,
  entitlementCodes: ['BASIC_REMINDERS', 'EMERGENCY_ALERTS'],
);

const premium = SubscriptionPlan(
  id: 'premium',
  name: 'Guardian Premium',
  price: 29.90,
  currency: 'PEN',
  billingCycle: 'MONTHLY',
  active: true,
  requiresPayment: true,
  entitlementCodes: [
    'BASIC_REMINDERS',
    'EMERGENCY_ALERTS',
    'FALL_DETECTION',
    'GEOFENCING',
    'HEALTH_MONITORING',
    'REAL_TIME_LOCATION',
  ],
);

final periodStart = DateTime.utc(2026, 11, 26);
final periodEnd = DateTime.utc(2026, 12, 26);
final renewedEnd = DateTime.utc(2027, 1, 26);

Subscription createSubscription({
  required SubscriptionPlan plan,
  String status = 'ACTIVE',
  DateTime? end,
  bool cancellationScheduled = false,
}) {
  return Subscription(
    id: 'subscription-1',
    subscriberId: 'subscriber-1',
    planId: plan.id,
    status: status,
    currentPeriodStart: status == 'PENDING' ? null : periodStart,
    currentPeriodEnd: status == 'PENDING' ? null : (end ?? periodEnd),
    cancelAtPeriodEnd: cancellationScheduled,
    createdAt: periodStart,
    updatedAt: periodStart,
  );
}

SubscriptionSummary createSummary({
  required SubscriptionPlan plan,
  String status = 'ACTIVE',
  DateTime? end,
  bool cancellationScheduled = false,
  bool includeEntitlements = true,
}) {
  return SubscriptionSummary(
    subscription: createSubscription(
      plan: plan,
      status: status,
      end: end,
      cancellationScheduled: cancellationScheduled,
    ),
    entitlements: status == 'PENDING' || !includeEntitlements
        ? []
        : plan.entitlementCodes
              .map(
                (code) => Entitlement(code: code, name: code, description: ''),
              )
              .toList(),
  );
}

class FakeSubscriptionRepository implements SubscriptionRepository {
  SubscriptionSummary? summary;

  bool failLoading = false;

  int subscriptionRequests = 0;
  int activationRequests = 0;
  int renewalRequests = 0;
  int changePlanRequests = 0;
  int cancellationRequests = 0;

  PaymentInitiation payment = const PaymentInitiation(
    provider: 'stripe',
    externalReference: 'pi_unit_test',
    status: 'PENDING',
    clientSecret: 'unit_test_client_secret',
  );

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    if (failLoading) {
      throw StateError('Catalog unavailable');
    }

    return [basic, premium];
  }

  @override
  Future<SubscriptionSummary?> getCurrentSubscription(
    String subscriberId,
  ) async {
    return summary;
  }

  @override
  Future<Subscription> requestSubscription({
    required String subscriberId,
    required String planId,
  }) async {
    subscriptionRequests++;

    final plan = planId == basic.id ? basic : premium;

    summary = createSummary(
      plan: plan,
      status: plan.requiresPayment ? 'PENDING' : 'ACTIVE',
    );

    return summary!.subscription;
  }

  @override
  Future<PaymentInitiation> initiateActivationPayment(
    String subscriptionId,
  ) async {
    activationRequests++;
    return payment;
  }

  @override
  Future<PaymentInitiation> initiateRenewalPayment(
    String subscriptionId,
  ) async {
    renewalRequests++;
    return payment;
  }

  @override
  Future<Subscription> changePlan({
    required String subscriptionId,
    required String newPlanId,
  }) async {
    changePlanRequests++;

    final plan = newPlanId == basic.id ? basic : premium;

    summary = createSummary(plan: plan);

    return summary!.subscription;
  }

  @override
  Future<Subscription> requestCancellation(String subscriptionId) async {
    cancellationRequests++;

    final plan = summary?.subscription.planId == basic.id ? basic : premium;

    summary = createSummary(
      plan: plan,
      end: summary?.subscription.currentPeriodEnd,
      cancellationScheduled: true,
    );

    return summary!.subscription;
  }
}

class FakeStripePaymentService extends StripePaymentService {
  bool configured = true;

  int presentations = 0;

  PaymentSheetOutcome outcome = PaymentSheetOutcome.completed;

  FutureOr<void> Function()? onPresent;

  @override
  bool get isConfigured => configured;

  @override
  Future<PaymentSheetOutcome> present(PaymentInitiation payment) async {
    presentations++;

    await onPresent?.call();

    return outcome;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeSubscriptionRepository repository;
  late FakeStripePaymentService paymentService;
  late MyPlanViewModel viewModel;

  setUp(() {
    repository = FakeSubscriptionRepository();
    paymentService = FakeStripePaymentService();
    SharedPreferences.setMockInitialValues({});

    viewModel = MyPlanViewModel(
      repository: repository,
      subscriberId: 'subscriber-1',
      paymentService: paymentService,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('Persistent payment recovery', () {
    test('waits when Stripe is processing without client secret', () async {
      repository.payment = const PaymentInitiation(
        provider: 'stripe',
        externalReference: 'pi_processing',
        status: 'PENDING',
      );

      await viewModel.load();

      await viewModel.selectPlan(premium);

      expect(paymentService.presentations, 0);
      expect(repository.activationRequests, 1);
      expect(viewModel.awaitingConfirmation, isTrue);
      expect(viewModel.canMutate, isFalse);
      expect(viewModel.message, PlanMessage.awaitingConfirmation);

      repository.summary = createSummary(plan: premium);

      await viewModel.load();

      expect(viewModel.awaitingConfirmation, isFalse);
      expect(viewModel.current?.isActive, isTrue);
      expect(viewModel.message, PlanMessage.updated);
    }, timeout: Timeout(Duration(seconds: 45)));

    test('recovers an uncertain renewal after reopening the page', () async {
      repository.summary = createSummary(plan: premium);

      paymentService.onPresent = () {
        throw StateError('Connection interrupted');
      };

      await viewModel.load();

      await viewModel.renew();

      expect(repository.renewalRequests, 1);
      expect(viewModel.awaitingConfirmation, isTrue);

      final preferences = await SharedPreferences.getInstance();

      const key = 'guardian_plus.subscriptions.pending_renewal.v1.subscriber-1';

      expect(preferences.getString(key), isNotNull);

      final reopened = MyPlanViewModel(
        repository: repository,
        subscriberId: 'subscriber-1',
        paymentService: paymentService,
      );

      addTearDown(reopened.dispose);

      await reopened.load();

      expect(reopened.awaitingConfirmation, isTrue);
      expect(reopened.canRenew, isFalse);

      await reopened.renew();

      expect(repository.renewalRequests, 1);

      repository.summary = createSummary(plan: premium, end: renewedEnd);

      await reopened.load();

      expect(reopened.awaitingConfirmation, isFalse);
      expect(reopened.current?.currentPeriodEnd, renewedEnd);
      expect(reopened.message, PlanMessage.updated);
      expect(preferences.getString(key), isNull);
    });

    test(
      'clears persisted renewal after explicit payment cancellation',
      () async {
        repository.summary = createSummary(plan: premium);

        paymentService.outcome = PaymentSheetOutcome.cancelled;

        await viewModel.load();

        await viewModel.renew();

        final preferences = await SharedPreferences.getInstance();

        const key =
            'guardian_plus.subscriptions.pending_renewal.v1.subscriber-1';

        expect(repository.renewalRequests, 1);
        expect(viewModel.awaitingConfirmation, isFalse);
        expect(viewModel.canRenew, isTrue);
        expect(viewModel.message, PlanMessage.paymentCancelled);
        expect(preferences.getString(key), isNull);
      },
    );
  });

  group('Subscription catalog', () {
    test('loads plans without an active subscription', () async {
      await viewModel.load();

      expect(viewModel.plans.length, 2);
      expect(viewModel.current, isNull);
      expect(viewModel.loadFailed, isFalse);
      expect(viewModel.canSelectPlan(basic), isTrue);
      expect(viewModel.canSelectPlan(premium), isTrue);
    });

    test('disables operations when loading fails', () async {
      repository.failLoading = true;

      await viewModel.load();

      expect(viewModel.loadFailed, isTrue);
      expect(viewModel.canMutate, isFalse);
    });

    test('allows retry after catalog loading failure', () async {
      repository.failLoading = true;
      await viewModel.load();

      repository.failLoading = false;
      await viewModel.load();

      expect(viewModel.loadFailed, isFalse);
      expect(viewModel.plans.length, 2);
    });
  });

  group('Subscription activation', () {
    test('activates Basic without opening Stripe', () async {
      await viewModel.load();

      await viewModel.selectPlan(basic);

      expect(viewModel.current?.isActive, isTrue);
      expect(viewModel.current?.planId, basic.id);
      expect(viewModel.summary?.entitlements.length, 2);
      expect(repository.subscriptionRequests, 1);
      expect(repository.activationRequests, 0);
      expect(paymentService.presentations, 0);
      expect(viewModel.message, PlanMessage.updated);
    });

    test('activates Premium after backend confirmation', () async {
      paymentService.onPresent = () {
        repository.summary = createSummary(plan: premium);
      };

      await viewModel.load();
      await viewModel.selectPlan(premium);

      expect(repository.subscriptionRequests, 1);
      expect(repository.activationRequests, 1);
      expect(paymentService.presentations, 1);
      expect(viewModel.current?.isActive, isTrue);
      expect(viewModel.summary?.entitlements.length, 6);
      expect(viewModel.message, PlanMessage.updated);
      expect(viewModel.awaitingConfirmation, isFalse);
    });

    test('keeps subscription pending when payment is cancelled', () async {
      paymentService.outcome = PaymentSheetOutcome.cancelled;

      await viewModel.load();
      await viewModel.selectPlan(premium);

      expect(viewModel.current?.isPending, isTrue);
      expect(viewModel.summary?.entitlements, isEmpty);
      expect(viewModel.message, PlanMessage.paymentCancelled);
      expect(viewModel.canSelectPlan(premium), isTrue);
      expect(viewModel.canSelectPlan(basic), isFalse);
    });

    test('resumes an existing pending subscription', () async {
      repository.summary = createSummary(plan: premium, status: 'PENDING');

      paymentService.onPresent = () {
        repository.summary = createSummary(plan: premium);
      };

      await viewModel.load();
      await viewModel.selectPlan(premium);

      expect(repository.subscriptionRequests, 0);
      expect(repository.activationRequests, 1);
      expect(viewModel.current?.isActive, isTrue);
    });

    test('blocks paid activation without Stripe configuration', () async {
      paymentService.configured = false;

      await viewModel.load();
      await viewModel.selectPlan(premium);

      expect(repository.subscriptionRequests, 0);
      expect(paymentService.presentations, 0);
      expect(viewModel.message, PlanMessage.stripeNotConfigured);
    });

    test('blocks unsupported direct paid plan changes', () async {
      repository.summary = createSummary(plan: basic);

      await viewModel.load();
      await viewModel.selectPlan(premium);

      expect(viewModel.canSelectPlan(premium), isFalse);
      expect(repository.changePlanRequests, 0);
      expect(repository.activationRequests, 0);
    });

    test('prevents concurrent activation requests', () async {
      final gate = Completer<void>();

      paymentService.onPresent = () async {
        await gate.future;
        repository.summary = createSummary(plan: premium);
      };

      await viewModel.load();

      final operation = viewModel.selectPlan(premium);

      await viewModel.selectPlan(premium);

      gate.complete();

      await operation;

      expect(repository.subscriptionRequests, 1);
      expect(repository.activationRequests, 1);
      expect(paymentService.presentations, 1);
    });
  });

  group('Payment confirmation', () {
    test('blocks another payment until backend confirmation arrives', () async {
      await viewModel.load();
      await viewModel.selectPlan(premium);

      expect(viewModel.awaitingConfirmation, isTrue);
      expect(viewModel.canMutate, isFalse);
      expect(viewModel.current?.isPending, isTrue);

      await viewModel.selectPlan(premium);

      expect(repository.activationRequests, 1);

      repository.summary = createSummary(plan: premium);

      await viewModel.load();

      expect(viewModel.awaitingConfirmation, isFalse);
      expect(viewModel.current?.isActive, isTrue);
      expect(viewModel.message, PlanMessage.updated);
    }, timeout: Timeout(Duration(seconds: 45)));
  });

  group('Renewal and cancellation', () {
    test('renews only after the subscription period advances', () async {
      repository.summary = createSummary(plan: premium);

      paymentService.onPresent = () {
        repository.summary = createSummary(plan: premium, end: renewedEnd);
      };

      await viewModel.load();
      await viewModel.renew();

      expect(repository.renewalRequests, 1);
      expect(paymentService.presentations, 1);
      expect(viewModel.current?.currentPeriodEnd, renewedEnd);
      expect(viewModel.message, PlanMessage.updated);
    });

    test('does not offer paid renewal for Basic', () async {
      repository.summary = createSummary(plan: basic);

      await viewModel.load();

      expect(viewModel.canRenew, isFalse);

      await viewModel.renew();

      expect(repository.renewalRequests, 0);
    });

    test('schedules cancellation without removing access', () async {
      repository.summary = createSummary(plan: premium);

      await viewModel.load();

      final cancelled = await viewModel.cancelAtPeriodEnd();

      expect(cancelled, isTrue);
      expect(repository.cancellationRequests, 1);
      expect(viewModel.current?.isCancellationScheduled, isTrue);
      expect(viewModel.current?.currentPeriodEnd, periodEnd);
      expect(viewModel.summary?.entitlements.length, 6);
      expect(viewModel.canCancel, isFalse);
      expect(viewModel.canRenew, isFalse);
      expect(viewModel.message, PlanMessage.cancellationSucceeded);
    });
  });
}
