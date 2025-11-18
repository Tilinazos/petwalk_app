import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/route_entity.dart';
import '../../domain/usecases/get_optimized_route.dart';

// ===============================================
// 1. INTERFAZ ABSTRACTA (El Contrato)
// ===============================================

abstract class RouteRemoteDataSource {
  /// Obtiene los datos de la ruta optimizada del servidor remoto (FastAPI).
  /// Retorna una [RouteEntity] si es exitoso.
  /// Lanza una [Exception] si falla la conexión o el servidor devuelve un error.
  Future<RouteEntity> getOptimizedRoute(RouteParams params);
}

// ===============================================
// 2. IMPLEMENTACIÓN CONCRETA
// ===============================================

class RouteRemoteDataSourceImpl implements RouteRemoteDataSource {
  final http.Client client;

  RouteRemoteDataSourceImpl({required this.client});

  @override
  Future<RouteEntity> getOptimizedRoute(RouteParams params) async {
    // Nota: La URL 10.0.2.2 es el alias de localhost en Android emulators
    final response = await client.post(
      Uri.parse('http://10.0.2.2:8000/v1/routes/optimize'), 
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        // Estos campos deben coincidir exactamente con los campos de tu modelo OptimizationRequest de FastAPI
        'start_lat': params.startLat,
        'start_lon': params.startLon,
        'max_time_minutes': params.maxTimeMinutes,
        'is_cycle': true, // Asumimos ciclo para el caso de uso principal
        'walking_pace': params.walkingPace,
      }),
    );

    if (response.statusCode == 200) {
      // Mapear el JSON de FastAPI a la Entidad de Dominio
      final jsonResponse = json.decode(response.body);
      
      return RouteEntity(
        route: (jsonResponse['route'] as List)
            .map((i) => Coordinate(lat: i['lat'].toDouble(), lon: i['lon'].toDouble()))
            .toList(),
        totalQuality: jsonResponse['total_quality'].toDouble(),
        totalTimeMinutes: jsonResponse['total_time_minutes'].toDouble(),
        distanceKm: jsonResponse['distance_km'].toDouble(),
      );
    } else if (response.statusCode == 404) {
       // La API de FastAPI devuelve 404 si el algoritmo no encuentra una ruta
       throw Exception('404: Ruta no encontrada para los parámetros dados.');
    } else {
      // Manejo de otros errores (400 Bad Request, 500 Internal Server Error, etc.)
      throw Exception('Fallo al cargar los datos del servidor. Status: ${response.statusCode}');
    }
  }
}