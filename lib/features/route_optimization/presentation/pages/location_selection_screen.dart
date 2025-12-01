import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/session_service.dart';
import 'route_params_screen.dart';
import '../../../auth/presentation/pages/profile_screen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final MapController _mapController = MapController();
  late LatLng _markerPosition;

  @override
  void initState() {
    super.initState();
    // Ubicación por defecto: Lima Centro
    _markerPosition = const LatLng(-12.1115, -77.0305);
  }

  void _useCurrentLocation() {
    setState(() {
      _markerPosition = const LatLng(-12.1115, -77.0305);
    });
    
    _mapController.move(_markerPosition, 15.0);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usando ubicación: Lima Centro'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _markerPosition = position;
    });
  }

  void _continueToParams() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RouteParamsScreen(
          startLat: _markerPosition.latitude,
          startLon: _markerPosition.longitude,
        ),
      ),
    );
  }

  void _zoomIn() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planifica tu Paseo'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black87,
        actions: [
          Consumer<SessionService>(
            builder: (context, sessionService, child) {
              return IconButton(
                icon: const Icon(Icons.person),
                onPressed: _navigateToProfile,
                tooltip: 'Perfil',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // === MAPA INTERACTIVO ===
                Expanded(
                  child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _markerPosition,
                initialZoom: 15.0,
                onTap: _onMapTap,
              ),
              children: [
                // Capa de Tiles (OpenStreetMap)
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.petwalkapp',
                ),
                
                // Capa de Marcador (Ubicación seleccionada)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _markerPosition,
                      width: 50.0,
                      height: 50.0,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50.0,
                      ),
                    ),
                  ],
                ),
              ],
                  ),
                ),

                // === PANEL INFERIOR CON CONTROLES ===
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Coordenadas actuales
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Lat: ${_markerPosition.latitude.toStringAsFixed(4)}, '
                        'Lon: ${_markerPosition.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Instrucciones
                Text(
                  'Toca el mapa para cambiar la ubicación de inicio',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _useCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Mi ubicación actual'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _continueToParams,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Continuar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
            ],
          ),
          // === CONTROLES DE ZOOM ===
          Positioned(
            top: 16,
            right: 16,
            child: _ZoomControls(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
            ),
          ),
        ],
        ),
      ),
    );
  }
}

// Widget para los controles de zoom
class _ZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _ZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón Zoom In (+)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onZoomIn,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),
          ),
          // Línea divisoria
          Container(
            width: 44,
            height: 1,
            color: Colors.grey.shade300,
          ),
          // Botón Zoom Out (-)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onZoomOut,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.remove,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

