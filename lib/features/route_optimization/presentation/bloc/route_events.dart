import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_optimized_route.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();
  @override
  List<Object> get props => [];
}

/// Evento disparado cuando el usuario hace clic en "Planificar Ruta"
class GetOptimizedRouteEvent extends RouteEvent {
  final RouteParams params;

  const GetOptimizedRouteEvent({required this.params});

  @override
  List<Object> get props => [params];
}