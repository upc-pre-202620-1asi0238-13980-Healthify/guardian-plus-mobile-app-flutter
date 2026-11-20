import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/presentation/care_circle/care_circle_view_model.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

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
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.viewModel;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            ProfileTopBar(
              title: l10n.profileCareCircle,
              subtitle: l10n.careCircleSubtitle,
              onBack: widget.onBack,
            ),

            const SizedBox(height: 22),

            ProfileInfoBanner(text: l10n.careCircleInfo),

            const SizedBox(height: 24),

            ProfileSectionTitle(title: l10n.careCircleMembers),

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
                    Text(l10n.careCircleLoadError, textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: state.load,
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              )
            else if (state.members.isEmpty)
              ProfileCard(
                child: Column(
                  children: [
                    Icon(Icons.people_outline_rounded, size: 32),
                    SizedBox(height: 10),
                    Text(l10n.careCircleEmpty, textAlign: TextAlign.center),
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
                      l10n.careCirclePrivacy,
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
    final l10n = context.l10n;

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
                  _relationshipLabel(context, member.relationshipLabel),
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
              l10n.careCircleActive,
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

  String _relationshipLabel(BuildContext context, String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized == 'family' || normalized == 'familiar') {
      return context.l10n.relationshipFamily;
    }

    if (normalized == 'caregiver' || normalized == 'cuidador') {
      return context.l10n.relationshipCaregiver;
    }

    return value;
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
