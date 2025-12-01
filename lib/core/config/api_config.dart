// core/config/api_config.dart
class ApiConfig {
  // URL base del backend desplegado
  static const String baseUrl = 'https://petwalk-api-6fm7.onrender.com';
  
  // Endpoints
  static const String optimizeRouteEndpoint = '/api/v1/routes/optimize';
  
  // URL completa para optimizar ruta
  static String get optimizeRouteUrl => '$baseUrl$optimizeRouteEndpoint';
}

