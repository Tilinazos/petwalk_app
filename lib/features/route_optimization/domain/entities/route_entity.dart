class RouteEntity {
  final List<Coordinate> route;
  final double totalQuality;
  final double totalTimeMinutes;
  final double distanceKm;
  final String? message;

  RouteEntity({
    required this.route,
    required this.totalQuality,
    required this.totalTimeMinutes,
    required this.distanceKm,
    this.message,
  });
}

class Coordinate {
  final double lat;
  final double lon;

  Coordinate({required this.lat, required this.lon});
}