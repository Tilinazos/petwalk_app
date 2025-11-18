abstract class Failure {
  final String message;
  Failure({required this.message});
}

// Fallo si el servidor no responde o hay un problema de red/HTTP 500
class ServerFailure extends Failure {
  ServerFailure({required super.message});
}

// Fallo si la ruta no se encuentra (HTTP 404 de tu API)
class NotFoundFailure extends Failure {
  NotFoundFailure({required super.message});
}

// Fallo genérico
class UnknownFailure extends Failure {
  UnknownFailure({required super.message});
}