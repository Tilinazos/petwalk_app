class RouteEntity {
  final List<Coordinate> route;
  final double totalQuality;
  final double totalTimeMinutes;
  final double distanceKm;
  final String? message; // ✅ Cambiar de getter a propiedad

  RouteEntity({
    required this.route,
    required this.totalQuality,
    required this.totalTimeMinutes,
    required this.distanceKm,
    this.message, // ✅ Ahora es opcional
  });
}

class Coordinate {
  final double lat;
  final double lon;

  Coordinate({required this.lat, required this.lon});
}