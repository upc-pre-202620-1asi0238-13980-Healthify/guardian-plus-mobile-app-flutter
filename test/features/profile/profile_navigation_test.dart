import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/profile/presentation/navigation/profile_navigation.dart';

void main() {
  setUp(() {
    getIt.registerSingleton<CareContextStore>(
      CareContextStore()..save(
        const CareContext(
          userAccountId: 'user-1',
          userFullName: 'María Rojas',
          careRecipientProfileId: 'recipient-1',
          careRecipientName: 'Elena Rojas',
        ),
      ),
    );
  });
  tearDown(() => getIt.reset());

  Widget app(VoidCallback onLogout) => MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => openProfile(context, onLogout: onLogout),
          child: const Text('Abrir perfil'),
        ),
      ),
    ),
  );

  testWidgets('opens settings and terms and returns to the account menu', (
    tester,
  ) async {
    await tester.pumpWidget(app(() {}));
    await tester.tap(find.text('Abrir perfil'));
    await tester.pumpAndSettle();
    expect(find.text('María Rojas'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Configuración'), 250);
    await tester.tap(find.text('Configuración'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Términos y condiciones'), 250);
    await tester.tap(find.text('Términos y condiciones'));
    await tester.pumpAndSettle();
    expect(find.text('ÚLTIMA ACTUALIZACIÓN: 2026'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('María Rojas'), -250);
    expect(find.text('María Rojas'), findsOneWidget);
  });

  testWidgets(
    'cancel keeps the session and confirmation calls the shell once',
    (tester) async {
      var logouts = 0;
      await tester.pumpWidget(app(() => logouts++));
      await tester.tap(find.text('Abrir perfil'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Cerrar sesión'), 250);
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(logouts, 0);
      expect(getIt<CareContextStore>().current, isNotNull);
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cerrar sesión'));
      await tester.pumpAndSettle();
      expect(logouts, 1);
    },
  );
}
