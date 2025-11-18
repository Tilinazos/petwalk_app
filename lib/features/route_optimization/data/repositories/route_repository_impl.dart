// features/route_optimization/data/repositories/route_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/usecases/get_optimized_route.dart';
import '../../domain/repositories/route_repository.dart';
import '../datasources/route_remote_datasource.dart';

class RouteRepositoryImpl implements RouteRepository {
  final RouteRemoteDataSource remoteDataSource;

  RouteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RouteEntity>> getOptimizedRoute(RouteParams params) async {
    try {
      // 1. Llamar a la fuente de datos (la API de FastAPI)
      final routeModel = await remoteDataSource.getOptimizedRoute(params);
      
      // 2. Si la llamada es exitosa, retornar el resultado
      return Right(routeModel); // Right indica éxito, conteniendo la entidad
    } on Exception catch (e) {
      // 3. Manejar errores y convertirlos a Fallos de la aplicación
      if (e.toString().contains('404')) {
        return Left(NotFoundFailure(message: e.toString()));
      }
      if (e.toString().contains('Fallo')) {
        return Left(ServerFailure(message: e.toString()));
      }
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}