import 'package:dartz/dartz.dart'; // Librería común para manejo de errores/éxito
import '../../../../core/error/failures.dart'; // Modelo de Fallo/Error
import '../entities/route_entity.dart';
import '../repositories/route_repository.dart';

class GetOptimizedRoute {
  final RouteRepository repository;

  GetOptimizedRoute(this.repository);

  Future<Either<Failure, RouteEntity>> call(RouteParams params) async {
    return await repository.getOptimizedRoute(params);
  }
}

class RouteParams {
  final double startLat;
  final double startLon;
  final int maxTimeMinutes;
  final String walkingPace;
  final bool isCycle;
  
  RouteParams({
    required this.startLat,
    required this.startLon,
    required this.maxTimeMinutes,
    required this.walkingPace,
    required this.isCycle,
  });
}