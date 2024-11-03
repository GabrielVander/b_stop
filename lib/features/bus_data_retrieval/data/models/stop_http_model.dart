import 'package:b_stop/features/bus_stops/domain/dtos/stop_output.dart' show StopOutput;
import 'package:equatable/equatable.dart' show Equatable;
import 'package:latlong2/latlong.dart' show LatLng;

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

  StopOutput toEntity() => StopOutput(id: stopId, name: name, postion: LatLng(lat, lng));
}
