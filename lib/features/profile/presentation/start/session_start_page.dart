import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/main/main_page.dart';
import 'package:guardian_plus_app/features/profile/application/care_context_load.dart';
import 'package:guardian_plus_app/features/profile/application/load_care_context_use_case.dart';

class SessionStartPage extends StatefulWidget {
  const SessionStartPage({super.key});

  @override
  State<SessionStartPage> createState() => _SessionStartPageState();
}

class _SessionStartPageState extends State<SessionStartPage> {
  String? errorMessage;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await getIt<LoadCareContextUseCase>().execute();

      if (!mounted) return;

      if (result is CareContextReady) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainPage()),
          (_) => false,
        );

        return;
      }

      if (result is CareContextOnboardingRequired) {
        final missing = <String>[];

        if (result.needsUserProfile) {
          missing.add('tu perfil personal');
        }

        if (result.needsCareRecipient) {
          missing.add('la persona bajo cuidado');
        }

        setState(() {
          loading = false;
          errorMessage =
              'La cuenta inició sesión correctamente, '
              'pero todavía falta configurar ${missing.join(' y ')}.';
        });

        return;
      }

      setState(() {
        loading = false;
        errorMessage = 'No se pudo preparar tu cuenta.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sheet,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: loading
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Cargando tu cuenta...'),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_search_outlined,
                        size: 52,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        errorMessage ?? 'No se pudo cargar tu cuenta.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: _load,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
