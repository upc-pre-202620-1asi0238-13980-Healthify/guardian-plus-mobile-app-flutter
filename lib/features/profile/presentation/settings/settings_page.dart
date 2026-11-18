import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onLanguage;
  final VoidCallback onAccessibility;
  final VoidCallback onTerms;
  final VoidCallback onAbout;

  const SettingsPage({
    super.key,
    required this.onBack,
    required this.onLanguage,
    required this.onAccessibility,
    required this.onTerms,
    required this.onAbout,
  });

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
              title: 'Configuración',
              subtitle: 'Preferencias de la aplicación',
              onBack: onBack,
            ),
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
                    onTap: onLanguage,
                  ),
                  const Divider(height: 1),
                  ProfileMenuTile(
                    icon: Icons.accessibility_new_rounded,
                    title: 'Accesibilidad',
                    subtitle: 'Texto, contraste y asistencia',
                    onTap: onAccessibility,
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
                    onTap: onTerms,
                  ),
                  const Divider(height: 1),
                  ProfileMenuTile(
                    icon: Icons.info_outline,
                    title: 'Acerca de Guardian+',
                    subtitle: 'Información de la aplicación',
                    onTap: onAbout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const ProfileInfoBanner(
              text: 'Puedes ajustar estas preferencias en cualquier momento.',
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
  }
}
