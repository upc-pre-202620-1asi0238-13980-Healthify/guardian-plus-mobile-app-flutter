import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

class AboutPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onTerms;

  const AboutPage({super.key, required this.onBack, required this.onTerms});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            ProfileTopBar(
              title: l10n.settingsAbout,
              subtitle: l10n.settingsAboutSubtitle,
              onBack: onBack,
            ),
            const SizedBox(height: 22),
            ProfileCard(
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.health_and_safety_outlined,
                      color: theme.colorScheme.primary,
                      size: 29,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Guardian+',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.aboutTagline,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _VersionChip(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ProfileSectionTitle(title: l10n.aboutSection),
            ProfileCard(child: Text(l10n.aboutDescription)),
            const SizedBox(height: 24),
            ProfileSectionTitle(title: l10n.aboutInformation),
            ProfileCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _InfoRow(label: l10n.aboutAppVersion, value: '1.0'),
                  const Divider(height: 1),
                  _InfoRow(
                    label: l10n.aboutDevelopedBy,
                    value: 'Healthify',
                    valueColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ProfileSectionTitle(title: l10n.aboutLegalInformation),
            ProfileCard(
              padding: EdgeInsets.zero,
              child: ProfileMenuTile(
                icon: Icons.description_outlined,
                title: l10n.settingsTerms,
                subtitle: l10n.aboutTermsSubtitle,
                onTap: onTerms,
              ),
            ),
            const SizedBox(height: 16),
            ProfileInfoBanner(text: l10n.aboutThanks),
          ],
        ),
      ),
    );
  }
}

class _VersionChip extends StatelessWidget {
  const _VersionChip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.aboutVersion,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: 16),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
