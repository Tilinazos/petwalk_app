import 'package:equatable/equatable.dart';
import '../../domain/entities/route_entity.dart';

abstract class RouteState extends Equatable {
  const RouteState();
  @override
  List<Object> get props => [];
}

class RouteInitial extends RouteState {}

class RouteLoading extends RouteState {}

class RouteLoaded extends RouteState {
  final RouteEntity route;

  const RouteLoaded({required this.route});

  @override
  List<Object> get props => [route];
}

class RouteError extends RouteState {
  final String message;

  const RouteError({required this.message});

  @override
  List<Object> get props => [message];
}