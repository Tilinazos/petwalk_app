// features/route_optimization/presentation/manager/route_bloc_consumer.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petwalk_app/features/route_optimization/presentation/pages/result_screen.dart'; // La pantalla de resultados
import '../bloc/route_bloc.dart';
import '../bloc/route_states.dart';

class RouteBlocConsumer extends StatefulWidget {
  final Widget child;

  const RouteBlocConsumer({super.key, required this.child});

  @override
  State<RouteBlocConsumer> createState() => _RouteBlocConsumerState();
}

class _RouteBlocConsumerState extends State<RouteBlocConsumer> {
  DateTime? _dialogShownAt;
  bool _isDialogVisible = false;

  Future<void> _showGeneratingDialog(BuildContext context) {
    if (_isDialogVisible) return Future.value();
    _isDialogVisible = true;
    _dialogShownAt = DateTime.now();

    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Generando recorrido',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      useRootNavigator: true,
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return const _GeneratingStatusOverlay();
      },
    );
  }

  Future<void> _hideDialogRespectingDelay(BuildContext context) async {
    if (!_isDialogVisible) return;

    const minDuration = Duration(seconds: 3);
    final elapsed =
        DateTime.now().difference(_dialogShownAt ?? DateTime.now());
    final remaining = minDuration - elapsed;

    if (remaining.inMilliseconds > 0) {
      await Future.delayed(remaining);
    }

    if (!mounted || !_isDialogVisible) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    _isDialogVisible = false;
    _dialogShownAt = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RouteBloc, RouteState>(
      listener: (context, state) async {
        if (state is RouteLoading) {
          _showGeneratingDialog(context);
        } else if (state is RouteLoaded) {
          await _hideDialogRespectingDelay(context);
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ResultScreen(route: state.route),
            ),
          );
        } else if (state is RouteError) {
          await _hideDialogRespectingDelay(context);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return widget.child;
      },
    );
  }
}

class _GeneratingStatusOverlay extends StatelessWidget {
  const _GeneratingStatusOverlay();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/animations/video-flutter.gif',
                  height: 210,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Generando recorrido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Estamos preparando la ruta ideal, esto tomará solo unos segundos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              const LinearProgressIndicator(
                minHeight: 6,
                color: Colors.amber,
                backgroundColor: Color(0xFFFFECB3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}