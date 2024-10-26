import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class Stop extends Equatable {
  const Stop({required this.id, required this.name, required this.postion});

  final String id;
  final String name;
  final LatLng postion;

  @override
  List<Object?> get props => [id, name, postion.latitude, postion.longitude];
}
