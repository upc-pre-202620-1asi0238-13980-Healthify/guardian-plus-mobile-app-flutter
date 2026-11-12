import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/components/ack_timeout_selector.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/components/contacts_summary_card.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/components/setting_switch_row.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/components/settings_section.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/detail_top_bar.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/navigation/emergency_alerting_navigation.dart';

class AlertSettingsPage extends StatefulWidget {
  final AlertSettingsViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<AlertSettingsPage> createState() => _AlertSettingsPageState();
}

class _AlertSettingsPageState extends State<AlertSettingsPage> {
  late final AlertSettingsViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_showActionError);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_showActionError);
    // The page owns its view model: every visit starts with a fresh one (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  void _showActionError() {
    final message = _viewModel.state.actionErrorMessage;
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    _viewModel.onActionErrorShown();
  }

  Future<void> _openContacts() async {
    await openEmergencyContacts(context);
    // Coming back from the contacts screen, the summary may be out of date
    _viewModel.refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailTopBar(
        title: 'Configuración de alertas',
        subtitle: _viewModel.state.careRecipientName,
        onBackPressed: Navigator.canPop(context) ? () => Navigator.pop(context) : null,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          final state = _viewModel.state;
          final settings = state.settings;

          if (settings == null && state.errorMessage != null) {
            return ErrorRetryView(message: state.errorMessage!, onRetry: _viewModel.loadSettings);
          }
          if (settings == null) {
            return const LoadingView();
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              ContactsSummaryCard(
                contactCount: state.contacts.length,
                primaryContactName: state.primaryContact?.displayName,
                onTap: _openContacts,
              ),
              const SizedBox(height: 20),
              _EscalationSection(settings: settings, enabled: !state.isSavingSettings, viewModel: _viewModel),
              const SizedBox(height: 20),
              SettingsSection(
                title: 'Sonido de las alertas',
                children: [
                  SettingSwitchRow(
                    title: 'Silenciar alertas no críticas',
                    detail: 'Las alertas de ${state.careRecipientFirstName} que no son críticas llegan sin sonido '
                        'a los celulares del círculo de cuidado. Las caídas y los SOS siempre suenan.',
                    icon: Icons.notifications_off_outlined,
                    value: settings.silentModeEnabled,
                    enabled: !state.isSavingSettings,
                    onChanged: _viewModel.setSilentModeEnabled,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ChannelsSection(state: state, onChanged: _viewModel.setChannelEnabled),
            ],
          );
        },
      ),
    );
  }
}

class _EscalationSection extends StatelessWidget {
  final AlertSettings settings;
  final bool enabled;
  final AlertSettingsViewModel viewModel;

  const new({required this.settings, required this.enabled, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Escalamiento',
      children: [
        SettingSwitchRow(
          title: 'Avisar a los siguientes contactos',
          detail: 'Si el contacto principal no reconoce una alerta crítica o alta, se envía a los demás.',
          value: settings.escalationEnabled,
          enabled: enabled,
          onChanged: viewModel.setEscalationEnabled,
        ),
        // The timeout only matters while escalation is on
        AckTimeoutSelector(
          selectedSeconds: settings.primaryAckTimeoutSec,
          enabled: enabled && settings.escalationEnabled,
          onSelected: viewModel.setAckTimeout,
        ),
        const Padding(padding: EdgeInsets.only(top: 8), child: Divider()),
        SettingSwitchRow(
          title: 'Avisar a todos ante caídas y SOS',
          detail: 'Las alertas críticas llegan a todo el círculo de cuidado al mismo tiempo.',
          value: settings.broadcastCriticalImmediately,
          enabled: enabled,
          onChanged: viewModel.setBroadcastCriticalImmediately,
        ),
      ],
    );
  }
}

class _ChannelsSection extends StatelessWidget {
  final AlertSettingsState state;
  final void Function(NotificationChannel channel, bool enabled) onChanged;

  const new({required this.state, required this.onChanged});

  static const _channels = [
    (NotificationChannel.push, 'Notificación push', Icons.smartphone),
    (NotificationChannel.sms, 'Mensaje de texto (SMS)', Icons.sms_outlined),
    (NotificationChannel.inApp, 'Dentro de la app', Icons.notifications_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final enabledChannels = state.enabledChannels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSection(
          title: 'Cómo te avisamos a ti',
          children: [
            for (final (channel, label, icon) in _channels)
              SettingSwitchRow(
                title: label,
                icon: icon,
                value: enabledChannels.contains(channel),
                // The last channel keeps its switch active so it reads as "on"; turning it off explains why it cannot
                enabled: state.savingChannel == null,
                onChanged: (enabled) => onChanged(channel, enabled),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 8),
          child: Text(
            'Las alertas críticas siempre se respaldan por SMS. Debe quedar al menos un canal activo.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
