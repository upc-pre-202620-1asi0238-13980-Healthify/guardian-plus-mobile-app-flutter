import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';
import 'package:guardian_plus_app/features/profile/presentation/settings/settings_view_model.dart';

class SettingsPage extends StatefulWidget {
  final SettingsViewModel viewModel;
  final VoidCallback onBack;
  final VoidCallback onLanguage;
  final VoidCallback onAccessibility;
  final VoidCallback onTerms;
  final VoidCallback onAbout;

  const SettingsPage({
    super.key,
    required this.viewModel,
    required this.onBack,
    required this.onLanguage,
    required this.onAccessibility,
    required this.onTerms,
    required this.onAbout,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _initializationPromptShown = false;

  @override
  void initState() {
    super.initState();

    widget.viewModel.load();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _promptInitialization() async {
    if (!mounted ||
        _initializationPromptShown ||
        !widget.viewModel.needsInitialization) {
      return;
    }

    _initializationPromptShown = true;

    final notificationsEnabled = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Notificaciones de Guardian+'),
          content: const Text('¿Deseas recibir notificaciones de Guardian+?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No recibir'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Recibir'),
            ),
          ],
        );
      },
    );

    if (!mounted || notificationsEnabled == null) {
      return;
    }

    final saved = await widget.viewModel.initializePreferences(
      notificationsEnabled: notificationsEnabled,
    );

    if (!mounted) {
      return;
    }

    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferencias configuradas correctamente.'),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('No se pudieron configurar las preferencias.'),
        action: SnackBarAction(
          label: 'Reintentar',
          onPressed: () {
            setState(() {
              _initializationPromptShown = false;
            });

            _promptInitialization();
          },
        ),
      ),
    );
  }

  void _openLanguage() {
    if (widget.viewModel.isLoading || widget.viewModel.isSaving) {
      return;
    }

    if (widget.viewModel.needsInitialization) {
      _initializationPromptShown = false;
      _promptInitialization();
      return;
    }

    widget.onLanguage();
  }

  void _openAccessibility() {
    if (widget.viewModel.isLoading || widget.viewModel.isSaving) {
      return;
    }

    if (widget.viewModel.needsInitialization) {
      _initializationPromptShown = false;
      _promptInitialization();
      return;
    }

    widget.onAccessibility();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);

        final viewModel = widget.viewModel;

        if (!viewModel.isLoading &&
            viewModel.needsInitialization &&
            !_initializationPromptShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _promptInitialization();
          });
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [
                ProfileTopBar(
                  title: 'Configuración',
                  subtitle: 'Preferencias de la aplicación',
                  onBack: widget.onBack,
                ),

                if (viewModel.isLoading || viewModel.isSaving) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],

                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: 18),
                  _ErrorBanner(
                    message: viewModel.errorMessage!,
                    onRetry: () {
                      viewModel.clearError();

                      if (viewModel.needsInitialization) {
                        setState(() {
                          _initializationPromptShown = false;
                        });

                        _promptInitialization();
                      } else {
                        viewModel.load();
                      }
                    },
                  ),
                ],

                const SizedBox(height: 24),

                const ProfileSectionTitle(title: 'Preferencias'),

                ProfileCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.language_rounded,
                        title: 'Idioma',
                        subtitle: 'Español (Latinoamérica)',
                        onTap: _openLanguage,
                      ),
                      const Divider(height: 1),
                      ProfileMenuTile(
                        icon: Icons.accessibility_new_rounded,
                        title: 'Accesibilidad',
                        subtitle: 'Texto, contraste y asistencia',
                        onTap: _openAccessibility,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const ProfileSectionTitle(title: 'Aplicación'),

                ProfileCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.description_outlined,
                        title: 'Términos y condiciones',
                        subtitle: 'Condiciones de uso de Guardian+',
                        onTap: widget.onTerms,
                      ),
                      const Divider(height: 1),
                      ProfileMenuTile(
                        icon: Icons.info_outline,
                        title: 'Acerca de Guardian+',
                        subtitle: 'Información de la aplicación',
                        onTap: widget.onAbout,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const ProfileInfoBanner(
                  text:
                      'Puedes ajustar estas preferencias en cualquier momento.',
                ),

                const SizedBox(height: 32),

                Text(
                  'GUARDIAN+',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'Versión 1.0',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
