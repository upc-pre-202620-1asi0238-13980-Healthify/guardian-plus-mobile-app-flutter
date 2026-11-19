import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';

class AboutPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onTerms;

  const AboutPage({super.key, required this.onBack, required this.onTerms});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            ProfileTopBar(
              title: 'Acerca de Guardian+',
              subtitle: 'Información de la aplicación',
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
                    'Cuidado y monitoreo remoto',
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
            const ProfileSectionTitle(title: 'Sobre Guardian+'),
            const ProfileCard(
              child: Text(
                'Guardian+ ayuda a familiares y cuidadores a acompañar de forma remota a personas bajo cuidado mediante una experiencia centralizada y accesible.',
              ),
            ),
            const SizedBox(height: 24),
            const ProfileSectionTitle(title: 'Información'),
            ProfileCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  const _InfoRow(
                    label: 'Versión de la aplicación',
                    value: '1.0',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Desarrollado por',
                    value: 'Healthify',
                    valueColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const ProfileSectionTitle(title: 'Información legal'),
            ProfileCard(
              padding: EdgeInsets.zero,
              child: ProfileMenuTile(
                icon: Icons.description_outlined,
                title: 'Términos y condiciones',
                subtitle: 'Consulta las condiciones de uso de Guardian+',
                onTap: onTerms,
              ),
            ),
            const SizedBox(height: 16),
            const ProfileInfoBanner(
              text: 'Gracias por utilizar Guardian+ para acompañar el cuidado de las personas que más importan.',
            ),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Versión 1.0',
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
