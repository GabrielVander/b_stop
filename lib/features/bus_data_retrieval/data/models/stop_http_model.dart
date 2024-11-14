import 'package:b_stop/features/bus_stops/domain/entities/stop.dart';
import 'package:json/json.dart';

@JsonCodable()
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

  final String? stopCode;
  final double stopLat;
  final int distance;
  final String? street;
  final double stopLon;
  final String? streetNumber;
  final String stopId;
  final String label;
  final String stopName;

  Stop toEntity() => Stop(id: stopId, name: label, lat: stopLat, lon: stopLon);
}
