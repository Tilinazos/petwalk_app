// features/route_optimization/presentation/pages/result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/route_entity.dart';

class ResultScreen extends StatefulWidget {
  final RouteEntity route;

  const ResultScreen({super.key, required this.route});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final MapController _mapController = MapController();
  bool _showMetrics = true; // Para mostrar/ocultar el panel

  List<LatLng> get _routePoints {
    return widget.route.route
        .map((coord) => LatLng(coord.lat, coord.lon))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // Ajustar la cámara después de que se renderice el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToRoute();
    });
  }

  void _fitMapToRoute() {
    final routePoints = _routePoints;
    if (routePoints.length > 1) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(routePoints),
          padding: const EdgeInsets.only(
            top: 50,
            left: 50,
            right: 50,
            bottom: 300, // Espacio para el panel de métricas
          ),
          maxZoom: 16.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _routePoints;
    final LatLng startPoint = routePoints.isNotEmpty 
        ? routePoints.first 
        : const LatLng(-12.1115, -77.0305);
    final LatLng endPoint = routePoints.isNotEmpty 
        ? routePoints.last 
        : startPoint;

    // Verificar si es una ruta circular
    final bool isCycle = startPoint.latitude == endPoint.latitude &&
        startPoint.longitude == endPoint.longitude;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 Ruta de Máxima Calidad'),
        backgroundColor: Colors.green,
        actions: [
          // Botón para centrar el mapa
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Centrar ruta',
            onPressed: _fitMapToRoute,
          ),
          // Botón para mostrar/ocultar métricas
          IconButton(
            icon: Icon(_showMetrics ? Icons.expand_more : Icons.expand_less),
            tooltip: _showMetrics ? 'Ocultar métricas' : 'Mostrar métricas',
            onPressed: () {
              setState(() {
                _showMetrics = !_showMetrics;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          // === MAPA CON LA RUTA ===
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: startPoint,
              initialZoom: 14.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              // 1. Capa de Tiles (OpenStreetMap)
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.petwalkapp',
              ),

              // 2. Capa de Polilínea (La Ruta Optimizada) 🎯
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    color: Colors.green.shade600,
                    strokeWidth: 6.0,
                    borderStrokeWidth: 2.0,
                    borderColor: Colors.black87,
                  ),
                ],
              ),

              // 3. Capa de Marcadores (Inicio y Fin)
              MarkerLayer(
                markers: [
                  // Marcador de INICIO (Rojo)
                  Marker(
                    point: startPoint,
                    width: 60.0,
                    height: 60.0,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'INICIO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ],
                    ),
                  ),
                  
                  // Marcador de FIN (Verde) - Solo si NO es ciclo
                  if (!isCycle)
                    Marker(
                      point: endPoint,
                      width: 60.0,
                      height: 60.0,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'FIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.flag,
                            color: Colors.green,
                            size: 40.0,
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // 4. Indicador de puntos intermedios (opcional)
              CircleLayer(
                circles: routePoints.asMap().entries.map((entry) {
                  // Muestra un círculo cada 5 puntos
                  if (entry.key % 5 == 0 && 
                      entry.key > 0 && 
                      entry.key < routePoints.length - 1) {
                    return CircleMarker(
                      point: entry.value,
                      radius: 4,
                      color: Colors.white,
                      borderColor: Colors.green.shade700,
                      borderStrokeWidth: 2,
                    );
                  }
                  return null;
                }).whereType<CircleMarker>().toList(),
              ),
            ],
          ),

          // === CONTADOR DE PUNTOS (Esquina superior izquierda) ===
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.route, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '${routePoints.length} puntos',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // === PANEL DE MÉTRICAS (Parte inferior) ===
          if (_showMetrics)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barra de arrastre
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Métricas de Optimización',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isCycle)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.refresh,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ruta Circular',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Métricas principales
                    _MetricRow(
                      icon: Icons.star,
                      iconColor: Colors.amber,
                      label: 'Calidad Total',
                      value: '${widget.route.totalQuality.toStringAsFixed(1)} pts',
                    ),
                    _MetricRow(
                      icon: Icons.timer,
                      iconColor: Colors.blue,
                      label: 'Tiempo Estimado',
                      value: '${widget.route.totalTimeMinutes.toStringAsFixed(1)} min',
                    ),
                    _MetricRow(
                      icon: Icons.straighten,
                      iconColor: Colors.green,
                      label: 'Distancia Total',
                      value: '${widget.route.distanceKm.toStringAsFixed(2)} km',
                    ),

                    // Velocidad promedio calculada
                    _MetricRow(
                      icon: Icons.speed,
                      iconColor: Colors.orange,
                      label: 'Velocidad Promedio',
                      value: '${((widget.route.distanceKm / widget.route.totalTimeMinutes) * 60).toStringAsFixed(1)} km/h',
                    ),

                    // Mensaje del algoritmo
                    if (widget.route.message != null &&
                        widget.route.message!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.route.message!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.edit_location),
                            label: const Text('Nueva Ruta'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.amber),
                              foregroundColor: Colors.amber.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Aquí podrías iniciar navegación GPS real
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🐾 ¡A pasear! Función de navegación próximamente...'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.pets),
                            label: const Text('¡COMENZAR PASEO!'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget helper para las filas de métricas
class _MetricRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MetricRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}