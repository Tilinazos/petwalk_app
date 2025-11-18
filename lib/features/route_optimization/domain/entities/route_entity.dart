class RouteEntity {
  final List<Coordinate> route;
  final double totalQuality;
  final double totalTimeMinutes;
  final double distanceKm;

  RouteEntity({
    required this.route,
    required this.totalQuality,
    required this.totalTimeMinutes,
    required this.distanceKm,
  });

  get message => null;
}

class Coordinate {
  final double lat;
  final double lon;

  Coordinate({required this.lat, required this.lon});
}