import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/auth/application/logout_use_case.dart';
import 'package:guardian_plus_app/features/auth/domain/session_repository.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_page.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_viewmodel.dart';
import 'package:guardian_plus_app/features/profile/application/profile_preferences_controller.dart';
import 'package:guardian_plus_app/features/profile/presentation/start/session_start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian_plus_app/l10n/app_localizations.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

bool _redirectingAfterInvalidToken = false;

void _handleInvalidToken() {
  if (_redirectingAfterInvalidToken) {
    return;
  }

  _redirectingAfterInvalidToken = true;

  getIt<LogoutUseCase>().execute();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final navigator = rootNavigatorKey.currentState;

    if (navigator != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginPage(viewModel: getIt<LoginViewmodel>()),
        ),
        (_) => false,
      );
    }

    _redirectingAfterInvalidToken = false;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  setupDependencies(
    preferences: preferences,
    onInvalidToken: _handleInvalidToken,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = getIt<ProfilePreferencesController>();
    final sessionRepository = getIt<SessionRepository>();

    return ListenableBuilder(
      listenable: preferences,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'Guardian+',
          debugShowCheckedModeBanner: false,

          locale: preferences.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          theme: GuardianTheme.light(
            highContrast: preferences.highContrastEnabled,
            reduceMotion: preferences.reduceMotionEnabled,
          ),
          builder: (context, child) {
            final media = MediaQuery.of(context);

            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(preferences.textScale),
                highContrast: preferences.highContrastEnabled,
                disableAnimations: preferences.reduceMotionEnabled,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: sessionRepository.currentSession() == null
              ? LoginPage(viewModel: getIt<LoginViewmodel>())
              : const SessionStartPage(),
        );
      },
    );
  }
}
