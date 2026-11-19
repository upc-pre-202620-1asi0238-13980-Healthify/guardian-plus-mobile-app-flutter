import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/domain/user_preferences.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';
import 'package:guardian_plus_app/features/profile/presentation/language/language_view_model.dart';

class LanguagePage extends StatefulWidget {
  final LanguageViewModel viewModel;
  final VoidCallback onBack;

  const LanguagePage({
    super.key,
    required this.viewModel,
    required this.onBack,
  });

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  @override
  void initState() {
    super.initState();

    widget.viewModel.addListener(_refresh);
    widget.viewModel.load();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_refresh);
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.viewModel;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                children: [
                  ProfileTopBar(
                    title: 'Idioma',
                    subtitle: 'Selecciona el idioma de Guardian+',
                    onBack: widget.onBack,
                  ),

                  const SizedBox(height: 24),

                  const ProfileSectionTitle(title: 'Idioma de la aplicación'),

                  ProfileCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _LanguageOption(
                          title: state.labelFor(
                            AppLanguage.spanishLatinAmerica,
                          ),
                          subtitle: 'Español',
                          selected:
                              state.selectedLanguage ==
                              AppLanguage.spanishLatinAmerica,
                          onTap: () {
                            state.selectLanguage(
                              AppLanguage.spanishLatinAmerica,
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _LanguageOption(
                          title: state.labelFor(
                            AppLanguage.englishUnitedStates,
                          ),
                          subtitle: 'English',
                          selected:
                              state.selectedLanguage ==
                              AppLanguage.englishUnitedStates,
                          onTap: () {
                            state.selectLanguage(
                              AppLanguage.englishUnitedStates,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _LanguageMessage(message: state.errorMessage!, error: true),
                  ],

                  if (state.successMessage != null) ...[
                    const SizedBox(height: 16),
                    _LanguageMessage(message: state.successMessage!),
                  ],

                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: state.isSaving ? null : state.save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar idioma'),
                  ),

                  const SizedBox(height: 16),

                  const ProfileInfoBanner(
                    text: 'La preferencia seleccionada se guarda en tu perfil de Guardian+.',
                  ),
                ],
              ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.language_rounded,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageMessage extends StatelessWidget {
  final String message;
  final bool error;

  const _LanguageMessage({required this.message, this.error = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final foreground = error
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: error
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            error
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: foreground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: foreground)),
          ),
        ],
      ),
    );
  }
}
