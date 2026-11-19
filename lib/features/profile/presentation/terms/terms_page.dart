import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';

class TermsPage extends StatelessWidget {
  final VoidCallback onBack;

  const TermsPage({super.key, required this.onBack});

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
              title: 'Términos y condiciones',
              subtitle: 'Uso de Guardian+',
              onBack: onBack,
            ),
            const SizedBox(height: 24),
            Text(
              'ÚLTIMA ACTUALIZACIÓN: 2026',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            const ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TermsSection(
                    title: '1. Uso del servicio',
                    body: 'Guardian+ ofrece herramientas de apoyo para el cuidado y monitoreo remoto de personas bajo cuidado.',
                  ),
                  Divider(height: 28),
                  _TermsSection(
                    title: '2. Responsabilidades del usuario',
                    body: 'El usuario debe mantener actualizada la información registrada y utilizar la aplicación de manera responsable.',
                  ),
                  Divider(height: 28),
                  _TermsSection(
                    title: '3. Uso de la información',
                    body: 'La información proporcionada se utiliza para ofrecer y personalizar las funcionalidades disponibles en Guardian+.',
                  ),
                  Divider(height: 28),
                  _TermsSection(
                    title: '4. Disponibilidad del servicio',
                    body: 'Algunas funcionalidades dependen de la conectividad, del dispositivo vinculado y de los servicios disponibles.',
                  ),
                  Divider(height: 28),
                  _TermsSection(
                    title: '5. Cambios en las condiciones',
                    body: 'Guardian+ podrá actualizar estas condiciones y comunicará los cambios correspondientes.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const ProfileInfoBanner(
              text: 'Consulta periódicamente esta sección para conocer la versión vigente de las condiciones de uso.',
            ),
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
                'Volver',
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
