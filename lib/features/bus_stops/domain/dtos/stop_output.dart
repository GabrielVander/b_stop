import 'package:b_stop/features/bus_stops/domain/entities/stop.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class StopOutput extends Equatable {
  const StopOutput({required this.id, required this.name, required this.postion});

  factory StopOutput.fromStopEntity(Stop entity) =>
      StopOutput(id: entity.id, name: entity.name, postion: LatLng(entity.lat, entity.lon));

  final String id;
  final String name;
  final LatLng postion;

  @override
  List<Object?> get props => [id, name, postion.latitude, postion.longitude];
}
