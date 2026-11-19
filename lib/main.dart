import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_page.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_viewmodel.dart';
import 'package:guardian_plus_app/features/profile/application/profile_preferences_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  setupDependencies(preferences: preferences);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = getIt<ProfilePreferencesController>();

    return ListenableBuilder(
      listenable: preferences,
      builder: (context, _) {
        return MaterialApp(
          title: 'Guardian+',
          debugShowCheckedModeBanner: false,
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
          home: LoginPage(viewModel: getIt<LoginViewmodel>()),
        );
      },
    );
  }
}
