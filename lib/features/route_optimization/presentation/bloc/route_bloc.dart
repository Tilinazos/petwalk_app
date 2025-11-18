import 'package:bloc/bloc.dart';
import '../../../../core/error/failures.dart';
import 'route_events.dart';
import 'route_states.dart';
import '../../domain/usecases/get_optimized_route.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final GetOptimizedRoute getOptimizedRoute;

  // El BLoC recibe el Caso de Uso (inyección de dependencias)
  RouteBloc({required this.getOptimizedRoute}) : super(RouteInitial()) {
    // Definimos el mapeo de eventos
    on<GetOptimizedRouteEvent>(_onGetOptimizedRouteEvent);
  }

  // Función de mapeo para el evento principal
  void _onGetOptimizedRouteEvent(
      GetOptimizedRouteEvent event, Emitter<RouteState> emit) async {
    
    emit(RouteLoading()); // Cambia el estado a Carga (Muestra Spinner)

    // Llama al Caso de Uso (que a su vez llama al Repositorio -> DataSource -> FastAPI)
    final failureOrRoute = await getOptimizedRoute(event.params);

    // Usa la función 'fold' de dartz para manejar éxito o fallo
    failureOrRoute.fold(
      (failure) {
        // Mapea el fallo (Failure) a un estado de Error
        emit(RouteError(message: _mapFailureToMessage(failure)));
      },
      (route) {
        // Si hay éxito, emite el estado con la ruta cargada
        emit(RouteLoaded(route: route));
      },
    );
  }

  // Helper para convertir el objeto Failure en un mensaje legible para la UI
  String _mapFailureToMessage(Failure failure) {
    if (failure is NotFoundFailure) {
      return "404: No se encontró una ruta que cumpla con su tiempo y calidad. Intente un tiempo mayor.";
    } else if (failure is ServerFailure) {
      return "Error del servidor: Fallo al comunicarse con el algoritmo.";
    } else {
      return "Error inesperado al planificar el paseo. Vuelva a intentarlo.";
    }
  }
}