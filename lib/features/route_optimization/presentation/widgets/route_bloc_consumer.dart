// features/route_optimization/presentation/manager/route_bloc_consumer.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petwalk_app/features/route_optimization/presentation/pages/result_screen.dart'; // La pantalla de resultados
import '../bloc/route_bloc.dart';
import '../bloc/route_states.dart';


class RouteBlocConsumer extends StatelessWidget {
  final Widget child;

  const RouteBlocConsumer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RouteBloc, RouteState>(
      listener: (context, state) {
        // Lógica de navegación y mensajes
        if (state is RouteLoading) {
          // Muestra un diálogo de carga
          showDialog(
            context: context,
            builder: (ctx) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Calculando ruta óptima..."),
                ],
              ),
            ),
            barrierDismissible: false,
          );
        } else if (state is RouteLoaded) {
          // Cierra el diálogo de carga
          Navigator.of(context).pop(); 
          // Navega a la pantalla de resultados, pasando la ruta
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ResultScreen(route: state.route),
            ),
          );
        } else if (state is RouteError) {
          // Cierra el diálogo de carga (si estaba abierto)
          if (ModalRoute.of(context)?.isCurrent != true) {
             Navigator.of(context).pop();
          }
          // Muestra un mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // Renderiza el widget hijo (InputScreen)
        return child;
      },
    );
  }
}