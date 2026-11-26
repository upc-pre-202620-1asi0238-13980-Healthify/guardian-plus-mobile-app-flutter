import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/subscriptions/presentation/my_plan/my_plan_page.dart';
import 'package:guardian_plus_app/features/subscriptions/presentation/my_plan/my_plan_view_model.dart';
import 'package:guardian_plus_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'my_plan_view_model_test.dart' as fixtures;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> verifyMobileLayout(
    WidgetTester tester, {
    required Size size,
    double textScale = 1.0,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = fixtures.FakeSubscriptionRepository();

    final paymentService = fixtures.FakeStripePaymentService();

    final viewModel = MyPlanViewModel(
      repository: repository,
      subscriberId: 'subscriber-1',
      paymentService: paymentService,
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: GuardianTheme.light(highContrast: false, reduceMotion: false),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: MyPlanPage(viewModel: viewModel, onBack: () {}),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    expect(find.text('Guardian Basic'), findsOneWidget);

    final premiumPlan = find.text('Guardian Premium');

    await tester.scrollUntilVisible(
      premiumPlan,
      180,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();

    expect(premiumPlan, findsOneWidget);

    expect(find.text('Contratar plan'), findsWidgets);

    expect(tester.takeException(), isNull);

    // Rendering must not initiate subscriptions or payments.
    expect(repository.subscriptionRequests, 0);
    expect(repository.activationRequests, 0);
    expect(paymentService.presentations, 0);

    await tester.pumpWidget(const SizedBox.shrink());

    await tester.pumpAndSettle();
  }

  group('My Plan mobile layout', () {
    testWidgets('renders on a compact mobile screen', (tester) async {
      await verifyMobileLayout(tester, size: const Size(320, 640));
    });

    testWidgets('renders with accessibility text scaling', (tester) async {
      await verifyMobileLayout(
        tester,
        size: const Size(360, 800),
        textScale: 1.15,
      );
    });

    testWidgets('renders on a large mobile screen', (tester) async {
      await verifyMobileLayout(tester, size: const Size(412, 915));
    });
  });
}
