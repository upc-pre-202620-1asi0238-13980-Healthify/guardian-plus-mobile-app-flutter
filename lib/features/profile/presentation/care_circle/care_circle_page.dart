import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/presentation/care_circle/care_circle_view_model.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';

class CareCirclePage extends StatefulWidget {
  final CareCircleViewModel viewModel;
  final VoidCallback onBack;

  const CareCirclePage({
    super.key,
    required this.viewModel,
    required this.onBack,
  });

  @override
  State<CareCirclePage> createState() => _CareCirclePageState();
}

class _CareCirclePageState extends State<CareCirclePage> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.viewModel;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            ProfileTopBar(
              title: 'Círculo de cuidado',
              subtitle: 'Personas que participan en el cuidado',
              onBack: widget.onBack,
            ),

            const SizedBox(height: 22),

            const ProfileInfoBanner(
              text: 'Aquí puedes consultar las personas vinculadas actualmente al cuidado.',
            ),

            const SizedBox(height: 24),

            const ProfileSectionTitle(title: 'Miembros'),

            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null)
              ProfileCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 10),
                    Text(state.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: state.load,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else if (state.members.isEmpty)
              const ProfileCard(
                child: Column(
                  children: [
                    Icon(Icons.people_outline_rounded, size: 32),
                    SizedBox(height: 10),
                    Text(
                      'No hay miembros activos en el círculo de cuidado.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ProfileCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < state.members.length;
                      index++
                    ) ...[
                      _CareCircleMemberTile(member: state.members[index]),
                      if (index != state.members.length - 1)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 18),

            ProfileCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Las personas del círculo de cuidado pueden tener acceso a información necesaria para acompañar el cuidado según su relación.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareCircleMemberTile extends StatelessWidget {
  final CareCircleMember member;

  const _CareCircleMemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Text(
              _initials(member.displayName),
              style: TextStyle(
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
                Text(
                  member.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  member.relationshipLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Activo',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
