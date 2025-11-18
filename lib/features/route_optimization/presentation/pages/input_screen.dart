// features/route_optimization/presentation/pages/input_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:petwalk_app/features/route_optimization/presentation/widgets/route_bloc_consumer.dart';
import '../../domain/usecases/get_optimized_route.dart';
import '../bloc/route_bloc.dart';
import '../bloc/route_events.dart';

// Clase para almacenar los datos de entrada del usuario
class InputData {
  double lat = -12.1115; // Coordenada de inicio por defecto (Lima)
  double lon = -77.0305;
  int timeMinutes = 60; // 60 minutos por defecto
  bool isCycle = true;
  String walkingPace = 'ligero';
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final InputData _data = InputData();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  
  // Posición actual del marcador
  late LatLng _markerPosition;

  @override
  void initState() {
    super.initState();
    _markerPosition = LatLng(_data.lat, _data.lon);
  }

  void _planRoute() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Actualizar las coordenadas con la posición actual del marcador
      _data.lat = _markerPosition.latitude;
      _data.lon = _markerPosition.longitude;

      // Disparar el evento al BLoC con los parámetros del usuario
      final params = RouteParams(
        startLat: _data.lat,
        startLon: _data.lon,
        maxTimeMinutes: _data.timeMinutes,
        walkingPace: _data.walkingPace,
      );

      // Usamos BlocProvider.of para acceder al BLoC
      BlocProvider.of<RouteBloc>(context).add(GetOptimizedRouteEvent(params: params));
    }
  }

  void _useCurrentLocation() {
    // Por ahora usa la ubicación por defecto
    setState(() {
      _markerPosition = LatLng(-12.1115, -77.0305);
      _data.lat = -12.1115;
      _data.lon = -77.0305;
    });
    
    // Centrar el mapa en la nueva posición
    _mapController.move(_markerPosition, 15.0);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usando ubicación: Lima Centro'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    // Actualizar la posición del marcador cuando se toca el mapa
    setState(() {
      _markerPosition = position;
      _data.lat = position.latitude;
      _data.lon = position.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RouteBlocConsumer(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Planifica tu Paseo'),
          backgroundColor: Colors.amber,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // === SECCIÓN 1: UBICACIÓN ===
                const Text(
                  '📍 Ubicación de Inicio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
                // Coordenadas actuales
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Lat: ${_markerPosition.latitude.toStringAsFixed(4)}, '
                    'Lon: ${_markerPosition.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 10),
                
                // MAPA INTERACTIVO
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _markerPosition,
                        initialZoom: 15.0,
                        onTap: _onMapTap, // Permite mover el marcador tocando el mapa
                      ),
                      children: [
                        // 1. Capa de Tiles (OpenStreetMap)
                        TileLayer(
                          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.example.petwalkapp',
                        ),
                        
                        // 2. Capa de Marcador (Ubicación seleccionada)
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
                ),
                const SizedBox(height: 10),
                
                // Instrucciones
                Text(
                  '💡 Toca el mapa para cambiar la ubicación de inicio',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                
                // Botón para usar la ubicación actual
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Usar mi ubicación actual'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // === SECCIÓN 2: TIEMPO Y RITMO ===
                const Text(
                  '⏰ Tiempo y Ritmo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Slider de Tiempo
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiempo Máximo: ${_data.timeMinutes} minutos',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Slider(
                          value: _data.timeMinutes.toDouble(),
                          min: 15,
                          max: 120,
                          divisions: 21,
                          label: '${_data.timeMinutes} min',
                          activeColor: Colors.amber,
                          onChanged: (double value) {
                            setState(() {
                              _data.timeMinutes = value.round();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Ritmo de Caminata
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Ritmo de Caminata',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _data.walkingPace,
                  items: const [
                    DropdownMenuItem(
                      value: 'ligero',
                      child: Text('🚶 Paso Ligero (~4.5 km/h)'),
                    ),
                    DropdownMenuItem(
                      value: 'acelerado',
                      child: Text('🏃 Paso Acelerado (~5.4 km/h)'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _data.walkingPace = newValue!;
                    });
                  },
                  onSaved: (String? newValue) {
                    _data.walkingPace = newValue!;
                  },
                ),

                const SizedBox(height: 30),

                // === BOTÓN DE ACCIÓN ===
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _planRoute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('🐾 PLANIFICAR RUTA DE CALIDAD'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}