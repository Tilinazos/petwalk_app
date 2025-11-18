// core/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// Importar todas las implementaciones:
import '../features/route_optimization/data/datasources/route_remote_datasource.dart';
import '../features/route_optimization/data/repositories/route_repository_impl.dart';
import '../features/route_optimization/domain/repositories/route_repository.dart';
import '../features/route_optimization/domain/usecases/get_optimized_route.dart';
import '../features/route_optimization/presentation/bloc/route_bloc.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // 1. Capa de Presentación (BLoC)
  sl.registerFactory(() => RouteBloc(getOptimizedRoute: sl())); // BLoC requiere el Caso de Uso

  // 2. Capa de Dominio (Use Cases)
  sl.registerLazySingleton(() => GetOptimizedRoute(sl())); // Use Case requiere el Repositorio

  // 3. Capa de Datos (Repositories y Data Sources)
  sl.registerLazySingleton<RouteRepository>(
      () => RouteRepositoryImpl(remoteDataSource: sl())); // Repositorio requiere el DataSource
      
  sl.registerLazySingleton<RouteRemoteDataSource>(
      () => RouteRemoteDataSourceImpl(client: sl())); // DataSource requiere el cliente HTTP

  // 4. Externas (Librerías)
  sl.registerLazySingleton(() => http.Client()); // Cliente HTTP de la librería 'http'
}