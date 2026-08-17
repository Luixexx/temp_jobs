import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationPicker extends StatefulWidget {
  final void Function(double lat, double lng) onLocationSelected;
  const LocationPicker({super.key, required this.onLocationSelected});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? _selected;
  bool _isLocating = false;
  String? _errorMsg;

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _errorMsg = null;
    });
    try {
      // Pedimos permiso si todavía no lo dimos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _errorMsg = 'Permiso de ubicación denegado');
        return;
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => _errorMsg = 'Activa el GPS del celular');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _selected = latLng);
      widget.onLocationSelected(latLng.latitude, latLng.longitude);
    } catch (e) {
      setState(() => _errorMsg = 'No se pudo obtener la ubicación');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _onMapTap(TapPosition tapPos, LatLng point) {
    setState(() => _selected = point);
    widget.onLocationSelected(point.latitude, point.longitude);
  }

  @override
  Widget build(BuildContext context) {
    // Punto por defecto: Santo Domingo, si todavía no hay ninguno elegido
    final center = _selected ?? const LatLng(18.4861, -69.9312);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: _selected != null ? 15 : 12,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.temp_jobs',
                ),
                if (_selected != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selected!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: _isLocating
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: const Text('Usar mi ubicación'),
                onPressed: _isLocating ? null : _useCurrentLocation,
              ),
            ),
          ],
        ),
        if (_selected != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Lat: ${_selected!.latitude.toStringAsFixed(5)}, Lng: ${_selected!.longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        if (_errorMsg != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _errorMsg!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const Text(
          'Tocá el mapa para ajustar el punto exacto',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
