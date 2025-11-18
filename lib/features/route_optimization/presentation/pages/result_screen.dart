// features/route_optimization/presentation/pages/result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Librería de mapas (Leaflet/OSM)
import 'package:latlong2/latlong.dart';      // Manejo de coordenadas LatLng
import '../../domain/entities/route_entity.dart';

class ResultScreen extends StatelessWidget {
  final RouteEntity route;

  const ResultScreen({super.key, required this.route});

  // Convierte las coordenadas de la Entidad a LatLng (del paquete latlong2)
  List<LatLng> get _routePoints {
    return route.route.map((coord) => LatLng(coord.lat, coord.lon)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<LatLng> routePoints = _routePoints;
    final LatLng initialCenter = routePoints.isNotEmpty ? routePoints.first : const LatLng(0, 0);

    // Creamos un controlador para el mapa para poder centrar la cámara dinámicamente
    final MapController mapController = MapController();

    // Nota: El cálculo de los límites de la ruta para centrar el zoom es complejo
    // sin la librería Mapbox o Geopandas. Usaremos el centro inicial y un zoom fijo.

    // Después de que la UI se renderiza, ajustamos la cámara para incluir toda la ruta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (routePoints.length > 1) {
        mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(routePoints),
            padding: const EdgeInsets.all(50.0), // Padding para que no se pegue a los bordes
            maxZoom: 16.0, // Limita el zoom para no acercarse demasiado
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta de Máxima Calidad'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: <Widget>[
          // === MAPA (Usando FlutterMap) ===
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 14.0,
            ),
            children: [
              // 1. Capa de Tiles (Fuente de OpenStreetMap - ¡GRATIS!)
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.petwalkapp', // Reemplaza con tu paquete
              ),

              // 2. Capa de Marcadores (Inicio/Fin)
              MarkerLayer(
                markers: [
                  Marker(
                    point: initialCenter,
                    width: 50.0,
                    height: 50.0,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 50.0),
                  ),
                ],
              ),

              // 3. Capa de Polilínea (Trazado de la Ruta Optimizada)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    color: Colors.green.shade700, // Verde oscuro para la calidad
                    strokeWidth: 6.0,
                    borderStrokeWidth: 2.0,
                    borderColor: Colors.black54, 
                  ),
                ],
              ),
            ],
          ),

          // === PANEL DE MÉTRICAS (Validación de Resultados) ===
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              // El panel de métricas con fondo blanco
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Métricas de Optimización', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const Divider(),
                  // Muestra las métricas clave de tu algoritmo
                  Text('⭐ Calidad Total S(P): ${route.totalQuality.toStringAsFixed(1)} puntos'),
                  Text('⏱️ Tiempo Real T(P): ${route.totalTimeMinutes.toStringAsFixed(1)} minutos'),
                  Text('📏 Distancia Total: ${route.distanceKm.toStringAsFixed(2)} km'),
                  const SizedBox(height: 10),
                  
                  // Muestra el mensaje de feedback del algoritmo
                  if (route.message != null && route.message!.isNotEmpty) 
                    Text(
                      'Feedback: ${route.message!}', 
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey)
                    ),
                  
                  const SizedBox(height: 10),
                  
                  // Botón de Volver/Comenzar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(), // Vuelve a la pantalla de Input
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                      child: const Text('¡A PASEAR! (Volver al Inicio)'),
                    ),
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