import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petwalk_app/features/route_optimization/presentation/widgets/route_bloc_consumer.dart';
import '../../domain/usecases/get_optimized_route.dart';
import '../bloc/route_bloc.dart';
import '../bloc/route_events.dart';

class RouteParamsScreen extends StatefulWidget {
  final double startLat;
  final double startLon;

  const RouteParamsScreen({
    super.key,
    required this.startLat,
    required this.startLon,
  });

  @override
  State<RouteParamsScreen> createState() => _RouteParamsScreenState();
}

class _RouteParamsScreenState extends State<RouteParamsScreen> {
  int _timeMinutes = 60;
  String _walkingPace = 'ligero';
  bool _vueltaDiferente = false;

  void _planRoute() {
    final params = RouteParams(
      startLat: widget.startLat,
      startLon: widget.startLon,
      maxTimeMinutes: _timeMinutes,
      walkingPace: _walkingPace,
      isCycle: _vueltaDiferente,
    );

    BlocProvider.of<RouteBloc>(context).add(GetOptimizedRouteEvent(params: params));
  }

  @override
  Widget build(BuildContext context) {
    return RouteBlocConsumer(
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 60),

              // === SECCIÓN: TIEMPO ===
              const Text(
                'Minutos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Slider de Tiempo
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiempo Máximo: $_timeMinutes minutos',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _timeMinutes.toDouble(),
                        min: 15,
                        max: 120,
                        divisions: 21,
                        label: '$_timeMinutes min',
                        activeColor: Colors.amber,
                        onChanged: (double value) {
                          setState(() {
                            _timeMinutes = value.round();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // === SECCIÓN: VUELTA DIFERENTE ===
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vuelta Diferente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: _vueltaDiferente,
                        onChanged: (bool value) {
                          setState(() {
                            _vueltaDiferente = value;
                          });
                        },
                        activeColor: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // === SECCIÓN: RITMO DE PASEO ===
              const Text(
                'Ritmo de paseo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Botones de ritmo (segmented control style)
              Row(
                children: [
                  Expanded(
                    child: _PaceButton(
                      label: 'Ligero',
                      icon: '🚶',
                      value: 'ligero',
                      selectedValue: _walkingPace,
                      onTap: () {
                        setState(() {
                          _walkingPace = 'ligero';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PaceButton(
                      label: 'Acelerado',
                      icon: '🏃',
                      value: 'acelerado',
                      selectedValue: _walkingPace,
                      onTap: () {
                        setState(() {
                          _walkingPace = 'acelerado';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // === BOTÓN DE ACCIÓN ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _planRoute,
                  icon: const Icon(Icons.route),
                  label: const Text('Planificar Ruta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
                ),
              ),
              // Botón de regreso
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para los botones de ritmo
class _PaceButton extends StatelessWidget {
  final String label;
  final String icon;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;

  const _PaceButton({
    required this.label,
    required this.icon,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.amber.shade700 : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black87 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

