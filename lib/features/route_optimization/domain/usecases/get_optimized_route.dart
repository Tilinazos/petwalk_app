import 'package:dartz/dartz.dart'; // Librería común para manejo de errores/éxito
import '../../../../core/error/failures.dart'; // Modelo de Fallo/Error
import '../entities/route_entity.dart';
import '../repositories/route_repository.dart';

class GetOptimizedRoute {
  final RouteRepository repository;

  GetOptimizedRoute(this.repository);

  // El método call permite ejecutar la clase como una función: GetOptimizedRoute(repo)(params)
  Future<Either<Failure, RouteEntity>> call(RouteParams params) async {
    return await repository.getOptimizedRoute(params);
  }
}

class RouteParams {
  final double startLat;
  final double startLon;
  final int maxTimeMinutes;
  final String walkingPace;
  
  // Incluye todos los parámetros de tu FastAPI OptimizationRequest
  RouteParams({
    required this.startLat,
    required this.startLon,
    required this.maxTimeMinutes,
    required this.walkingPace,
  });
}