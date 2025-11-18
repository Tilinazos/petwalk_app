import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_optimized_route.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();
  @override
  List<Object> get props => [];
}

class GetOptimizedRouteEvent extends RouteEvent {
  final RouteParams params;

  const GetOptimizedRouteEvent({required this.params});

  @override
  List<Object> get props => [params];
}