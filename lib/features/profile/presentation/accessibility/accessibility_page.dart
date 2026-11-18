import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/domain/user_preferences.dart';
import 'package:guardian_plus_app/features/profile/presentation/accessibility/accessibility_view_model.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';

class AccessibilityPage extends StatefulWidget {
  final AccessibilityViewModel viewModel;
  final VoidCallback onBack;

  const AccessibilityPage({
    super.key,
    required this.viewModel,
    required this.onBack,
  });

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> {
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
                    title: 'Accesibilidad',
                    subtitle: 'Personaliza tu experiencia',
                    onBack: widget.onBack,
                  ),

                  const SizedBox(height: 24),

                  const ProfileSectionTitle(title: 'Visual'),

                  ProfileCard(
                    padding: EdgeInsets.zero,
                    child: _AccessibilitySwitch(
                      icon: Icons.contrast_rounded,
                      title: 'Alto contraste',
                      subtitle: 'Aumenta la diferencia visual entre elementos',
                      value: state.highContrastEnabled,
                      onChanged: state.setHighContrast,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const ProfileSectionTitle(title: 'Movimiento'),

                  ProfileCard(
                    padding: EdgeInsets.zero,
                    child: _AccessibilitySwitch(
                      icon: Icons.animation_outlined,
                      title: 'Reducir movimiento',
                      subtitle: 'Reduce animaciones y transiciones',
                      value: state.reduceMotionEnabled,
                      onChanged: state.setReduceMotion,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const ProfileSectionTitle(title: 'Tamaño del texto'),

                  ProfileCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < AppFontScale.values.length;
                          index++
                        ) ...[
                          _FontScaleOption(
                            label: state.fontScaleLabel(
                              AppFontScale.values[index],
                            ),
                            value: AppFontScale.values[index],
                            selected:
                                state.fontScale == AppFontScale.values[index],
                            onTap: () {
                              state.setFontScale(AppFontScale.values[index]);
                            },
                          ),
                          if (index != AppFontScale.values.length - 1)
                            const Divider(height: 1),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const ProfileSectionTitle(title: 'Vista previa'),

                  ProfileCard(
                    child: _AccessibilityPreview(
                      fontScale: state.fontScale,
                      highContrast: state.highContrastEnabled,
                    ),
                  ),

                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _AccessibilityMessage(
                      message: state.errorMessage!,
                      error: true,
                    ),
                  ],

                  if (state.successMessage != null) ...[
                    const SizedBox(height: 16),
                    _AccessibilityMessage(message: state.successMessage!),
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
                        : const Text('Guardar preferencias'),
                  ),

                  const SizedBox(height: 14),

                  const ProfileInfoBanner(
                    text: 'Estas preferencias se guardan en tu perfil para mantener una experiencia consistente.',
                  ),
                ],
              ),
      ),
    );
  }
}

class _AccessibilitySwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AccessibilitySwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
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

          const SizedBox(width: 12),

          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _FontScaleOption extends StatelessWidget {
  final String label;
  final AppFontScale value;
  final bool selected;
  final VoidCallback onTap;

  const _FontScaleOption({
    required this.label,
    required this.value,
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
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
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

class _AccessibilityPreview extends StatelessWidget {
  final AppFontScale fontScale;
  final bool highContrast;

  const _AccessibilityPreview({
    required this.fontScale,
    required this.highContrast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final scale = switch (fontScale) {
      AppFontScale.small => .9,
      AppFontScale.defaultScale => 1.0,
      AppFontScale.large => 1.18,
    };

    final foreground = highContrast
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ejemplo de texto',
          textScaler: TextScaler.linear(scale),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Así se visualizará parte del contenido de Guardian+ con el tamaño seleccionado.',
          textScaler: TextScaler.linear(scale),
          style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
        ),
      ],
    );
  }
}

class _AccessibilityMessage extends StatelessWidget {
  final String message;
  final bool error;

  const _AccessibilityMessage({required this.message, this.error = false});

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
