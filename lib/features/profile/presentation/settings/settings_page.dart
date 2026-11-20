import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/features/profile/application/profile_preferences_controller.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';
import 'package:guardian_plus_app/features/profile/presentation/settings/settings_view_model.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

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

  ProfilePreferencesController get _preferences =>
      getIt<ProfilePreferencesController>();

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

    final l10n = context.l10n;

    final notificationsEnabled = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsNotificationsTitle),
          content: Text(l10n.settingsNotificationsQuestion),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(l10n.settingsNotificationsNo),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(l10n.settingsNotificationsYes),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.settingsInitialized)));

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.settingsInitializationError),
        action: SnackBarAction(
          label: context.l10n.commonRetry,
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
      listenable: _preferences,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final theme = Theme.of(context);
            final l10n = context.l10n;
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
                      title: l10n.settingsTitle,
                      subtitle: l10n.settingsSubtitle,
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

                    ProfileSectionTitle(title: l10n.settingsPreferences),

                    ProfileCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ProfileMenuTile(
                            icon: Icons.language_rounded,
                            title: l10n.settingsLanguage,
                            subtitle: _preferences.languageLabel,
                            onTap: _openLanguage,
                          ),
                          const Divider(height: 1),
                          ProfileMenuTile(
                            icon: Icons.accessibility_new_rounded,
                            title: l10n.settingsAccessibility,
                            subtitle: l10n.settingsAccessibilitySubtitle,
                            onTap: _openAccessibility,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    ProfileSectionTitle(title: l10n.settingsApplication),

                    ProfileCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ProfileMenuTile(
                            icon: Icons.description_outlined,
                            title: l10n.settingsTerms,
                            subtitle: l10n.settingsTermsSubtitle,
                            onTap: widget.onTerms,
                          ),
                          const Divider(height: 1),
                          ProfileMenuTile(
                            icon: Icons.info_outline,
                            title: l10n.settingsAbout,
                            subtitle: l10n.settingsAboutSubtitle,
                            onTap: widget.onAbout,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    ProfileInfoBanner(text: l10n.settingsInfo),

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
                      l10n.settingsVersion,
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
          TextButton(onPressed: onRetry, child: Text(context.l10n.commonRetry)),
        ],
      ),
    );
  }
}
