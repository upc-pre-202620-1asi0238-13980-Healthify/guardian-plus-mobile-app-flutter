import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/common/zones_map.dart';
import 'package:latlong2/latlong.dart';

/// Create or edit a safe zone. Tap the map or type coordinates; [suggestedCenter] (the current position of the
/// care recipient) only pre-fills a new zone. Pops with the [SafeZoneDraft] to save.
class SafeZoneEditorPage extends StatefulWidget {
  final SafeZone? zone;
  final LatLng? suggestedCenter;

  const SafeZoneEditorPage({super.key, this.zone, this.suggestedCenter});

  @override
  State<SafeZoneEditorPage> createState() => _SafeZoneEditorPageState();
}

class _SafeZoneEditorPageState extends State<SafeZoneEditorPage> {
  late final _name = TextEditingController(text: widget.zone?.name);
  late final _radius = TextEditingController(text: widget.zone?.radiusMeters.toStringAsFixed(0));
  late final _latitude = TextEditingController(
    text: (widget.zone?.latitude ?? widget.suggestedCenter?.latitude)?.toString(),
  );
  late final _longitude = TextEditingController(
    text: (widget.zone?.longitude ?? widget.suggestedCenter?.longitude)?.toString(),
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _radius.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  double? _number(TextEditingController controller) => double.tryParse(controller.text.trim().replaceAll(',', '.'));

  LatLng? get _point {
    final lat = _number(_latitude);
    final lon = _number(_longitude);
    if (lat == null || lon == null || lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;
    return LatLng(lat, lon);
  }

  String? _coordinate(String? value, double limit) {
    final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (parsed == null || parsed.abs() > limit) return 'Valor no válido';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      SafeZoneDraft(
        name: _name.text.trim(),
        latitude: _number(_latitude)!,
        longitude: _number(_longitude)!,
        radiusMeters: _number(_radius)!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final point = _point;
    final radius = _number(_radius);
    final preview = point == null || radius == null || radius <= 0
        ? const <SafeZone>[]
        : [
            SafeZone(
              id: widget.zone?.id ?? 'preview',
              fragileCitizenId: widget.zone?.fragileCitizenId ?? '',
              name: _name.text,
              latitude: point.latitude,
              longitude: point.longitude,
              radiusMeters: radius,
              isActive: true,
            ),
          ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.zone == null ? 'Nueva zona segura' : 'Editar zona segura')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ZonesMap(
              zones: preview,
              focus: point,
              onTap: (tapped) => setState(() {
                _latitude.text = tapped.latitude.toStringAsFixed(6);
                _longitude.text = tapped.longitude.toStringAsFixed(6);
              }),
              height: 260,
              zoom: 16,
              emptyMessage: 'Escribe las coordenadas para ver la zona en el mapa',
            ),
            const SizedBox(height: 8),
            const Text('Toca el mapa para mover el centro de la zona.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nombre de la zona'),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => (value ?? '').trim().isEmpty ? 'Escribe un nombre' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _radius,
              decoration: const InputDecoration(labelText: 'Radio (metros)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
                return parsed == null || parsed <= 0 ? 'El radio debe ser mayor a 0' : null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitude,
                    decoration: const InputDecoration(labelText: 'Latitud'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (value) => _coordinate(value, 90),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitude,
                    decoration: const InputDecoration(labelText: 'Longitud'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (value) => _coordinate(value, 180),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _submit, child: const Text('Guardar zona')),
          ],
        ),
      ),
    );
  }
}
