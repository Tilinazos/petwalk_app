// features/route_optimization/presentation/pages/input_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petwalk_app/features/route_optimization/presentation/widgets/route_bloc_consumer.dart';
import '../../domain/usecases/get_optimized_route.dart';
import '../bloc/route_bloc.dart';
import '../bloc/route_events.dart';

// Clase para almacenar los datos de entrada del usuario
class InputData {
  double lat = -12.1215; // Coordenada de inicio por defecto (Miraflores, Lima)
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

  void _planRoute() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

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

  @override
  Widget build(BuildContext context) {
    // Usamos el widget RouteBlocConsumer para escuchar los estados del BLoC
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
                const Text('📍 Ubicación de Inicio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                // [Aquí iría el Widget de Mapa Interactivo con el Marcador Arrastrable]
                Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Center(child: Text("Mapa Interactivo (Mapbox GL)")),
                ),
                
                // Botón para usar la ubicación actual
                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para obtener el GPS y actualizar _data.lat y _data.lon
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Usar mi ubicación actual'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                ),
                const SizedBox(height: 20),

                // === SECCIÓN 2: TIEMPO Y RITMO ===
                const Text('⏰ Tiempo y Ritmo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // Slider de Tiempo (Control de la Restricción B)
                ListTile(
                  title: Text('Tiempo Máximo: ${_data.timeMinutes} minutos'),
                  subtitle: Slider(
                    value: _data.timeMinutes.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 21,
                    label: '${_data.timeMinutes}',
                    onChanged: (double value) {
                      setState(() {
                        _data.timeMinutes = value.round();
                      });
                    },
                  ),
                ),

                // Ritmo de Caminata (afecta el cálculo T(e) en el Back-End)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Ritmo de Caminata'),
                  value: _data.walkingPace,
                  items: const [
                    DropdownMenuItem(value: 'ligero', child: Text('Paso Ligero (~4.5 km/h)')),
                    DropdownMenuItem(value: 'acelerado', child: Text('Paso Acelerado (~5.4 km/h)')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _data.walkingPace = newValue!;
                    });
                  },
                  onSaved: (String? newValue) {
                    _data.walkingPace = newValue!;
                  }
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
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('PLANIFICAR RUTA DE CALIDAD'),
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