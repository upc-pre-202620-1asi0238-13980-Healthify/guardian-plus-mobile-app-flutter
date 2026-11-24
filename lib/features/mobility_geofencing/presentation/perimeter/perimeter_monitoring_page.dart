import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/application/location_use_cases.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/perimeter_monitor.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/call/call_page.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/call/call_view_model.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/common/mobility_widgets.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/common/zones_map.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/perimeter/location_history_page.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/perimeter/perimeter_monitoring_view_model.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/safe_zones/safe_zones_view_model.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/safe_zones/safe_zones_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Monitoreo perimetral" (US-18, EP04): live position on the map, inside/outside the safe zone, and the exit and
/// return alerts for the caregiver.
class PerimeterMonitoringPage extends StatefulWidget {
  final PerimeterMonitoringViewModel viewModel;

  const PerimeterMonitoringPage({super.key, required this.viewModel});

  @override
  State<PerimeterMonitoringPage> createState() => _PerimeterMonitoringPageState();
}

class _PerimeterMonitoringPageState extends State<PerimeterMonitoringPage> {
  late final PerimeterMonitoringViewModel _viewModel = widget.viewModel;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openZones() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => SafeZonesPage(viewModel: getIt<SafeZonesViewModel>())),
    );
    if (mounted) _viewModel.refresh();
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => LocationHistoryPage(
          getLocationHistory: getIt<GetLocationHistoryUseCase>(),
          fragileCitizenId: _viewModel.careContext.careRecipientProfileId,
          careRecipientFirstName: _viewModel.careContext.careRecipientFirstName,
        ),
      ),
    );
  }

  void _call() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => CallPage(viewModel: getIt<CallViewModel>(param1: CallType.voice)),
      ),
    );
  }

  Future<void> _navigate() async {
    final location = _viewModel.state.location;
    if (location == null) return;
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${location.latitude},${location.longitude}',
    });
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir la navegación')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _viewModel.careContext.careRecipientFirstName;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monitoreo perimetral'),
            Text(_viewModel.careContext.careRecipientName, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [IconButton(tooltip: 'Zonas seguras', onPressed: _openZones, icon: const Icon(Icons.shield_outlined))],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;
          if (state.isLoading && state.location == null && state.zones.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && state.location == null && state.zones.isEmpty) {
            return MobilityErrorState(message: state.errorMessage!, onRetry: _viewModel.refresh);
          }

          final event = state.event;
          return RefreshIndicator(
            onRefresh: _viewModel.refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (event != null && !state.eventDismissed)
                  _AlertBanner(event: event, firstName: firstName),
                if (event != null && !state.eventDismissed) const SizedBox(height: 16),
                ZonesMap(
                  zones: state.zones,
                  location: state.location,
                  outside: state.hasExited,
                  height: 280,
                  emptyMessage: 'Aún no hay ubicación ni zonas seguras para mostrar',
                ),
                const SizedBox(height: 16),
                _StatusCard(state: state, firstName: firstName),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 16),
                if (state.hasExited) ...[
                  FilledButton.icon(onPressed: _call, icon: const Icon(Icons.phone_outlined), label: Text('Llamar a $firstName')),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: state.location == null ? null : _navigate,
                    icon: const Icon(Icons.navigation_outlined),
                    label: const Text('Iniciar navegación / Seguir ruta'),
                  ),
                  TextButton(onPressed: _viewModel.dismissAlert, child: const Text('Descartar alerta')),
                ],
                OutlinedButton.icon(
                  onPressed: _openHistory,
                  icon: const Icon(Icons.list_alt_outlined),
                  label: const Text('Ver bitácora de movimientos'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final PerimeterEvent event;
  final String firstName;

  const _AlertBanner({required this.event, required this.firstName});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final exited = event.transition == PerimeterTransition.exited;
    final zone = event.zoneName ?? 'la zona segura';
    final distance = event.distanceOutsideMeters;

    final title = exited ? 'Salida de zona segura detectada' : 'Retorno a zona segura confirmado';
    final detail = exited
        ? '$firstName cruzó el perímetro de \'$zone\' a las ${formatTime(event.at)}.'
            '${distance == null ? '' : ' Distancia actual: +${distance.round()} m fuera del límite.'}'
        : '$firstName reingresó a \'$zone\' a las ${formatTime(event.at)}. Se restablece la vigilancia regular.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: exited ? colors.errorContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(exited ? Icons.warning_amber_rounded : Icons.verified_user_outlined,
              color: exited ? colors.onErrorContainer : colors.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(detail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final PerimeterMonitoringState state;
  final String firstName;

  const _StatusCard({required this.state, required this.firstName});

  @override
  Widget build(BuildContext context) {
    final location = state.location;
    final status = state.status;
    final zones = state.activeZones;

    final String headline;
    if (location == null) {
      headline = '$firstName aún no reportó ubicación';
    } else if (location.insideSafeZone) {
      headline = 'En zona segura${location.activeSafeZoneName == null ? '' : ': ${location.activeSafeZoneName}'}';
    } else {
      headline = zones.isEmpty ? 'Sin zonas seguras activas' : 'Fuera de las zonas seguras';
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(headline, style: Theme.of(context).textTheme.titleMedium),
            if (status != null && status.status.isNotEmpty) Text('Estado: ${_statusLabel(status.status)}'),
            if (location != null) Text('Última lectura: ${formatTime(location.timestamp)}'),
            if (location?.accuracy != null) Text('Precisión GPS: ±${location!.accuracy!.round()} m'),
          ],
        ),
      ),
    );
  }
}

/// Reader-friendly text of the platform's `LocationStatusResource.status`.
String _statusLabel(String wire) {
  return switch (wire) {
    'WITHIN_SAFE_ZONE' => 'Dentro de la zona segura',
    'OUTSIDE_SAFE_ZONE' => 'Fuera de la zona segura',
    'UNKNOWN' => 'Sin ubicación todavía',
    _ => wire,
  };
}
