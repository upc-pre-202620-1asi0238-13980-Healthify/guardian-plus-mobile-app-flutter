import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription.dart';

import 'dart:ui' show Color;

enum PaymentSheetOutcome { completed, cancelled }

class StripePaymentService {
  static const publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );

  bool _initialized = false;

  bool get isConfigured =>
      publishableKey.startsWith('pk_test_') ||
      publishableKey.startsWith('pk_live_');

  Future<void> initialize() async {
    if (_initialized) return;

    if (!isConfigured) {
      throw StateError('Stripe publishable key is not configured');
    }

    Stripe.publishableKey = publishableKey;

    await Stripe.instance.applySettings();

    _initialized = true;
  }

  Future<PaymentSheetOutcome> present(PaymentInitiation payment) async {
    if (!payment.canPresentPaymentSheet) {
      throw StateError('Payment is not ready for Stripe Payment Sheet');
    }

    await initialize();

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: payment.clientSecret!,
          merchantDisplayName: 'Guardian+',
          allowsDelayedPaymentMethods: false,

          linkDisplayParams: const LinkDisplayParams(
            linkDisplay: LinkDisplay.never,
          ),

          billingDetails: const BillingDetails(
            address: Address(
              city: null,
              country: 'PE',
              line1: null,
              line2: null,
              postalCode: null,
              state: null,
            ),
          ),

          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF157760),
              background: Color(0xFFF5F9F7),
              componentBackground: Color(0xFFFFFFFF),
              componentBorder: Color(0xFFCDDCD6),
              componentDivider: Color(0xFFCDDCD6),
              componentText: Color(0xFF173B32),
              primaryText: Color(0xFF173B32),
              secondaryText: Color(0xFF567069),
              placeholderText: Color(0xFF71847E),
              icon: Color(0xFF157760),
              error: Color(0xFFBA1A1A),
            ),
            shapes: PaymentSheetShape(borderRadius: 14, borderWidth: 1),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return PaymentSheetOutcome.completed;
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) {
        return PaymentSheetOutcome.cancelled;
      }

      rethrow;
    }
  }
}
