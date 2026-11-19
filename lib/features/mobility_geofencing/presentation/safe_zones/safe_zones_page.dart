import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/common/mobility_widgets.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/common/zones_map.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/safe_zones/safe_zone_editor_page.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/safe_zones/safe_zones_view_model.dart';
import 'package:latlong2/latlong.dart';

/// "Zonas seguras" (US-18 / EP04): map plus the list of authorized perimeters.
class SafeZonesPage extends StatefulWidget {
  final SafeZonesViewModel viewModel;

  const SafeZonesPage({super.key, required this.viewModel});

  @override
  State<SafeZonesPage> createState() => _SafeZonesPageState();
}

class _SafeZonesPageState extends State<SafeZonesPage> {
  late final SafeZonesViewModel _viewModel = widget.viewModel;
  String? _selectedId;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _toast(String? message) {
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _edit([SafeZone? zone]) async {
    final location = _viewModel.state.currentLocation;
    final draft = await Navigator.push<SafeZoneDraft>(
      context,
      MaterialPageRoute(
        builder: (context) => SafeZoneEditorPage(
          zone: zone,
          suggestedCenter: location == null ? null : LatLng(location.latitude, location.longitude),
        ),
      ),
    );
    if (draft == null) return;
    final error = await _viewModel.save(draft, existingId: zone?.id);
    _toast(error ?? 'Zona guardada');
  }

  Future<void> _delete(SafeZone zone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar zona'),
        content: Text('¿Eliminar "${zone.name}"? Dejará de vigilarse este perímetro.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed != true) return;
    _toast(await _viewModel.remove(zone) ?? 'Zona eliminada');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;
        final selected = state.zones.where((zone) => zone.id == _selectedId).firstOrNull;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Zonas seguras'),
                Text(
                  '${state.activeCount} geocercas activas',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [IconButton(tooltip: 'Nueva zona', onPressed: state.isSaving ? null : _edit, icon: const Icon(Icons.add))],
          ),
          body: switch (state) {
            SafeZonesState(isLoading: true, zones: []) => const Center(child: CircularProgressIndicator()),
            SafeZonesState(errorMessage: final message?, zones: []) => MobilityErrorState(message: message, onRetry: _viewModel.load),
            _ => RefreshIndicator(
              onRefresh: _viewModel.load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ZonesMap(
                    zones: state.zones,
                    location: state.currentLocation,
                    focus: selected == null ? null : LatLng(selected.latitude, selected.longitude),
                    highlightZoneId: _selectedId,
                    emptyMessage: 'Aún no hay zonas seguras ni ubicación para mostrar en el mapa',
                  ),
                  const SizedBox(height: 16),
                  Text('Perímetros autorizados', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (state.zones.isEmpty) const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Todavía no delimitaste ninguna zona segura.'),
                  ),
                  for (final zone in state.zones)
                    ListTile(
                      key: ValueKey(zone.id),
                      contentPadding: EdgeInsets.zero,
                      selected: zone.id == _selectedId,
                      leading: const Icon(Icons.shield_outlined),
                      title: Text(zone.name),
                      subtitle: Text('Radio: ${zone.radiusMeters.toStringAsFixed(0)} m'),
                      onTap: () => setState(() => _selectedId = zone.id),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: zone.isActive,
                            onChanged: state.isSaving ? null : (value) async => _toast(await _viewModel.toggle(zone, value)),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (action) => action == 'edit' ? _edit(zone) : _delete(zone),
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Editar')),
                              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: state.isSaving ? null : _edit,
                    icon: const Icon(Icons.add),
                    label: const Text('Delimitar nueva zona'),
                  ),
                ],
              ),
            ),
          },
        );
      },
    );
  }
}
