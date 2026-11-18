import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';

class ProfileHomePage extends StatelessWidget {
  final String userFullName;
  final String careRecipientName;

  final VoidCallback onBack;
  final VoidCallback onPersonalData;
  final VoidCallback onCareRecipient;
  final VoidCallback onCareCircle;
  final VoidCallback onWearable;
  final VoidCallback onMyPlan;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const ProfileHomePage({
    super.key,
    required this.userFullName,
    required this.careRecipientName,
    required this.onBack,
    required this.onPersonalData,
    required this.onCareRecipient,
    required this.onCareCircle,
    required this.onWearable,
    required this.onMyPlan,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initials(userFullName);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            ProfileTopBar(title: 'Perfil', onBack: onBack),
            const SizedBox(height: 18),
            ProfileCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Text(
                      initials,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userFullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const _RoleChip(label: 'Familiar'),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Cuida de $careRecipientName',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const ProfileSectionTitle(title: 'Cuenta'),
            ProfileCard(
              padding: EdgeInsets.zero,
              child: ProfileMenuTile(
                icon: Icons.person_outline_rounded,
                title: 'Mis datos',
                subtitle: 'Información personal y contacto',
                onTap: onPersonalData,
              ),
            ),
            const SizedBox(height: 20),
            const ProfileSectionTitle(title: 'Cuidado'),
            ProfileCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ProfileMenuTile(
                    icon: Icons.favorite_border_rounded,
                    title: 'Persona bajo cuidado',
                    subtitle: 'Información de $careRecipientName',
                    onTap: onCareRecipient,
                  ),
                  const Divider(height: 1),
                  ProfileMenuTile(
                    icon: Icons.people_outline_rounded,
                    title: 'Círculo de cuidado',
                    subtitle: 'Personas que participan en su cuidado',
                    onTap: onCareCircle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const ProfileSectionTitle(title: 'Dispositivo y plan'),
            ProfileCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ProfileMenuTile(
                    icon: Icons.watch_outlined,
                    title: 'Pulsera',
                    subtitle: 'Estado y preferencias del dispositivo',
                    onTap: onWearable,
                  ),
                  const Divider(height: 1),
                  ProfileMenuTile(
                    icon: Icons.star_border_rounded,
                    title: 'Mi plan',
                    subtitle: 'Suscripción y beneficios actuales',
                    onTap: onMyPlan,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const ProfileSectionTitle(title: 'Preferencias'),
            ProfileCard(
              padding: EdgeInsets.zero,
              child: ProfileMenuTile(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                subtitle: 'Preferencias de la aplicación',
                onTap: onSettings,
              ),
            ),
            const SizedBox(height: 16),
            ProfileCard(
              padding: EdgeInsets.zero,
              child: ProfileMenuTile(
                icon: Icons.logout_rounded,
                title: 'Cerrar sesión',
                subtitle: '',
                destructive: true,
                onTap: onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((value) => value.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _RoleChip extends StatelessWidget {
  final String label;

  const _RoleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
