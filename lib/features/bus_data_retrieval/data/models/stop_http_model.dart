import 'package:b_stop/features/bus_stops/domain/entities/stop.dart' show Stop;
import 'package:equatable/equatable.dart' show Equatable;

final class StopHttpModel extends Equatable {
  const StopHttpModel({
    required this.stopId,
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory StopHttpModel.fromJson(Map<String, dynamic> json) => StopHttpModel(
        stopId: json['stopId'] as String,
        name: json['label'] as String,
        lat: json['stopLat'] as double,
        lng: json['stopLon'] as double,
      );

  final String stopId;
  final String name;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [stopId, name, lat, lng];

  Stop toEntity() => Stop(id: stopId, name: name, lat: lat, lon: lng);
}
