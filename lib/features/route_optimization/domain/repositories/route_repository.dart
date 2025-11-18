// features/route_optimization/domain/repositories/route_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/route_entity.dart';
import '../usecases/get_optimized_route.dart';

abstract class RouteRepository {
  Future<Either<Failure, RouteEntity>> getOptimizedRoute(RouteParams params);
}