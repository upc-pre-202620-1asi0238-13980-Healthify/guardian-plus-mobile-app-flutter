import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

/// Yellow notice that explains the escalation rule, using the timeout configured for the person under care.
class EscalationNotice extends StatelessWidget {
  final int ackTimeoutSec;
  final VoidCallback onManageContacts;

  const new({super.key, required this.ackTimeoutSec, required this.onManageContacts});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GuardianColors.noticeContainer,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: GuardianColors.onNoticeContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.alertsEscalationNotice(ackTimeoutSec),
                  style: text.bodySmall?.copyWith(color: GuardianColors.onNoticeContainer),
                ),
                TextButton(
                  onPressed: onManageContacts,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                  child: Text(context.l10n.alertsManageContacts),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
