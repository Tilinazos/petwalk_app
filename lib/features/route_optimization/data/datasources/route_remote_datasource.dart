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
  // ✅ LOG: Ver qué se está enviando
  final requestBody = {
    'start_lat': params.startLat,
    'start_lon': params.startLon,
    'max_time_minutes': params.maxTimeMinutes,
    'is_cycle': true,
    'walking_pace': params.walkingPace,
  };
  
  print('🔵 REQUEST A API:');
  print(json.encode(requestBody));
  
  final response = await client.post(
    Uri.parse('http://10.0.2.2:8000/v1/routes/optimize'), 
    headers: {'Content-Type': 'application/json'},
    body: json.encode(requestBody),
  );

  // ✅ LOG: Ver qué responde la API
  print('🟢 RESPONSE STATUS: ${response.statusCode}');
  print('🟢 RESPONSE BODY: ${response.body}');

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    
    return RouteEntity(
      route: (jsonResponse['route'] as List)
          .map((i) => Coordinate(
                lat: i['lat'].toDouble(), 
                lon: i['lon'].toDouble(),
              ))
          .toList(),
      totalQuality: jsonResponse['total_quality'].toDouble(),
      totalTimeMinutes: jsonResponse['total_time_minutes'].toDouble(),
      distanceKm: jsonResponse['distance_km'].toDouble(),
      message: jsonResponse['message'] as String?,
    );
  } else if (response.statusCode == 404) {
     // ✅ LOG: Capturar el mensaje de error completo
     print('🔴 ERROR 404: ${response.body}');
     throw Exception('404: Ruta no encontrada para los parámetros dados.');
  } else {
    print('🔴 ERROR ${response.statusCode}: ${response.body}');
    throw Exception('Fallo al cargar los datos del servidor. Status: ${response.statusCode}');
  }
}
}