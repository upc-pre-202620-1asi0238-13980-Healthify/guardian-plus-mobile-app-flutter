import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

class TermsPage extends StatelessWidget {
  final VoidCallback onBack;

  const TermsPage({super.key, required this.onBack});

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
              title: l10n.settingsTerms,
              subtitle: l10n.termsSubtitle,
              onBack: onBack,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.termsLastUpdate,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TermsSection(title: l10n.terms1Title, body: l10n.terms1Body),
                  const Divider(height: 28),
                  _TermsSection(title: l10n.terms2Title, body: l10n.terms2Body),
                  const Divider(height: 28),
                  _TermsSection(title: l10n.terms3Title, body: l10n.terms3Body),
                  const Divider(height: 28),
                  _TermsSection(title: l10n.terms4Title, body: l10n.terms4Body),
                  const Divider(height: 28),
                  _TermsSection(title: l10n.terms5Title, body: l10n.terms5Body),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ProfileInfoBanner(text: l10n.termsInfo),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.commonBack,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String body;

  const _TermsSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          body,
          style: theme.textTheme.bodySmall?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
