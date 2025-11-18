import 'package:bloc/bloc.dart';
import '../../../../core/error/failures.dart';
import 'route_events.dart';
import 'route_states.dart';
import '../../domain/usecases/get_optimized_route.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final GetOptimizedRoute getOptimizedRoute;

  RouteBloc({required this.getOptimizedRoute}) : super(RouteInitial()) {
    on<GetOptimizedRouteEvent>(_onGetOptimizedRouteEvent);
  }

  void _onGetOptimizedRouteEvent(
      GetOptimizedRouteEvent event, Emitter<RouteState> emit) async {
    
    emit(RouteLoading());

    final failureOrRoute = await getOptimizedRoute(event.params);

    failureOrRoute.fold(
      (failure) {
        emit(RouteError(message: _mapFailureToMessage(failure)));
      },
      (route) {
        emit(RouteLoaded(route: route));
      },
    );
  }

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