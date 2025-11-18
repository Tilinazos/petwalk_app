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
        if (state is RouteLoading) {
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
          Navigator.of(context).pop(); 
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ResultScreen(route: state.route),
            ),
          );
        } else if (state is RouteError) {
          if (ModalRoute.of(context)?.isCurrent != true) {
             Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return child;
      },
    );
  }
}