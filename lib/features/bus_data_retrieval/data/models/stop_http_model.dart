import 'package:b_stop/core/utils/type_aliases/json.dart';
import 'package:b_stop/features/bus_stops/domain/entities/stop.dart';

final class StopHttpModel {
  const StopHttpModel({
    required this.stopLat,
    required this.distance,
    required this.stopLon,
    required this.stopId,
    required this.label,
    required this.stopName,
    this.stopCode,
    this.street,
    this.streetNumber,
  });

  factory StopHttpModel.fromJson(Json json) => StopHttpModel(
        stopLat: json['stopLat'] as double,
        distance: json['distance'] as int,
        stopLon: json['stopLon'] as double,
        stopId: json['stopId'] as String,
        label: json['label'] as String,
        stopName: json['stopName'] as String,
      );

  final String? stopCode;
  final double stopLat;
  final int distance;
  final String? street;
  final double stopLon;
  final String? streetNumber;
  final String stopId;
  final String label;
  final String stopName;

  Stop toEntity() => Stop(id: stopId, name: stopName, lat: stopLat, lon: stopLon);
}
