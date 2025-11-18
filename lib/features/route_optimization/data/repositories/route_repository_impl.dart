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
    final routeModel = await remoteDataSource.getOptimizedRoute(params);
    return Right(routeModel);
  } on Exception catch (e) {
    final errorMessage = e.toString();
    
    if (errorMessage.contains('404')) {
      return Left(NotFoundFailure(
        message: "No se encontró una ruta que cumpla con su tiempo y calidad. Intente un tiempo mayor."
      ));
    }
    if (errorMessage.contains('SocketException') || errorMessage.contains('Failed host lookup')) {
      return Left(ServerFailure(
        message: "Error de conexión: Verifique su conexión a internet y que el servidor esté activo."
      ));
    }
    if (errorMessage.contains('Status:')) {
      return Left(ServerFailure(
        message: "Error del servidor: $errorMessage"
      ));
    }
    
    return Left(UnknownFailure(
      message: "Error inesperado: $errorMessage"
    ));
  }
}
}