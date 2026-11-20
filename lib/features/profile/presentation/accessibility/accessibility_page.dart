import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/domain/user_preferences.dart';
import 'package:guardian_plus_app/features/profile/presentation/accessibility/accessibility_view_model.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

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

  String _fontScaleLabel(BuildContext context, AppFontScale value) {
    final l10n = context.l10n;

    switch (value) {
      case AppFontScale.small:
        return l10n.accessibilitySmall;

      case AppFontScale.defaultScale:
        return l10n.accessibilityDefault;

      case AppFontScale.large:
        return l10n.accessibilityLarge;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.viewModel;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                children: [
                  ProfileTopBar(
                    title: l10n.accessibilityTitle,
                    subtitle: l10n.accessibilitySubtitle,
                    onBack: widget.onBack,
                  ),

                  const SizedBox(height: 24),

                  ProfileSectionTitle(title: l10n.accessibilityVisual),

                  ProfileCard(
                    padding: EdgeInsets.zero,
                    child: _AccessibilitySwitch(
                      icon: Icons.contrast_rounded,
                      title: l10n.accessibilityHighContrast,
                      subtitle: l10n.accessibilityHighContrastDescription,
                      value: state.highContrastEnabled,
                      onChanged: state.setHighContrast,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ProfileSectionTitle(title: l10n.accessibilityMovement),

                  ProfileCard(
                    padding: EdgeInsets.zero,
                    child: _AccessibilitySwitch(
                      icon: Icons.animation_outlined,
                      title: l10n.accessibilityReduceMotion,
                      subtitle: l10n.accessibilityReduceMotionDescription,
                      value: state.reduceMotionEnabled,
                      onChanged: state.setReduceMotion,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ProfileSectionTitle(title: l10n.accessibilityTextSize),

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
                            label: _fontScaleLabel(
                              context,
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

                  ProfileSectionTitle(title: l10n.accessibilityPreview),

                  ProfileCard(
                    child: _AccessibilityPreview(
                      fontScale: state.fontScale,
                      highContrast: state.highContrastEnabled,
                    ),
                  ),

                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _AccessibilityMessage(
                      message: l10n.accessibilityUpdateError,
                      error: true,
                    ),
                  ],

                  if (state.successMessage != null) ...[
                    const SizedBox(height: 16),
                    _AccessibilityMessage(message: l10n.accessibilityUpdated),
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
                        : Text(l10n.accessibilitySave),
                  ),

                  const SizedBox(height: 14),

                  ProfileInfoBanner(text: l10n.accessibilityInfo),
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
    final l10n = context.l10n;

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
          l10n.accessibilityPreviewTitle,
          textScaler: TextScaler.linear(scale),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.accessibilityPreviewBody,
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
