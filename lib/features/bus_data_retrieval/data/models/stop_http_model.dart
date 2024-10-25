import 'package:b_stop/features/bus_stops/domain/entities/stop.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

final class StopHttpModel extends Equatable {
  const StopHttpModel({
    required this.stopId,
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory StopHttpModel.fromJson(Map<String, dynamic> json) {
    return StopHttpModel(
      stopId: json['stopId'] as String,
      name: json['name'] as String,
      lat: json['lat'] as double,
      lng: json['lng'] as double,
    );
  }

  final String stopId;
  final String name;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [stopId, name, lat, lng];

  Stop toEntity() => Stop(id: stopId, name: name, postion: LatLng(lat, lng));
}
