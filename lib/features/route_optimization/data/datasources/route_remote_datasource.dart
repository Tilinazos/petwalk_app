import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/route_entity.dart';
import '../../domain/usecases/get_optimized_route.dart';

abstract class RouteRemoteDataSource {
  Future<RouteEntity> getOptimizedRoute(RouteParams params);
}

class RouteRemoteDataSourceImpl implements RouteRemoteDataSource {
  final http.Client client;

  RouteRemoteDataSourceImpl({required this.client});

  @override
  Future<RouteEntity> getOptimizedRoute(RouteParams params) async {
    final requestBody = {
      'start_lat': params.startLat,
      'start_lon': params.startLon,
      'max_time_minutes': params.maxTimeMinutes,
      'is_cycle': params.isCycle,
      'walking_pace': params.walkingPace,
    };
    
    final response = await client.post(
      Uri.parse('http://10.0.2.2:8000/api/v1/routes/optimize'), 
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      
      return RouteEntity(
        route: (jsonResponse['route'] as List)
            .map((i) => Coordinate(
                  lat: (i['lat'] as num).toDouble(),
                  lon: (i['lon'] as num).toDouble(), 
                ))
            .toList(),
        totalQuality: (jsonResponse['total_quality'] as num).toDouble(),
        totalTimeMinutes: (jsonResponse['total_time_minutes'] as num).toDouble(),
        distanceKm: (jsonResponse['distance_km'] as num).toDouble(),
        message: jsonResponse['message'] as String?,
      );
    } else if (response.statusCode == 404) {
      throw Exception('404: Ruta no encontrada para los parámetros dados.');
    } else {
      throw Exception('Fallo al cargar los datos del servidor. Status: ${response.statusCode}');
    }
  }
}