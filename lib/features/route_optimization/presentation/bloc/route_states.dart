import 'package:equatable/equatable.dart';
import '../../domain/entities/route_entity.dart';

abstract class RouteState extends Equatable {
  const RouteState();
  @override
  List<Object> get props => [];
}

/// 1. Estado Inicial: Cuando la pantalla se carga por primera vez.
class RouteInitial extends RouteState {}

/// 2. Estado de Carga: Muestra un spinner mientras la API de FastAPI calcula la ruta.
class RouteLoading extends RouteState {}

/// 3. Estado Exitoso: El algoritmo devolvió la ruta óptima.
class RouteLoaded extends RouteState {
  final RouteEntity route;

  const RouteLoaded({required this.route});

  @override
  List<Object> get props => [route];
}

/// 4. Estado de Error: Falló la conexión o el algoritmo no encontró una ruta válida (404).
class RouteError extends RouteState {
  final String message;

  const RouteError({required this.message});

  @override
  List<Object> get props => [message];
}